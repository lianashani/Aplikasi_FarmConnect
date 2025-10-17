<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Transaction;
use App\Models\Product;
use App\Models\User;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Transaction::with('product');
        if ($user->role === 'admin') {
            // admin: all transactions
        } elseif ($user->role === 'petani') {
            // petani: transactions for their products
            $query->whereHas('product', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        } else {
            // pembeli: own transactions
            $query->where('user_id', $user->id);
        }
        $transactions = $query->latest('id')->paginate(20);

        return response()->json([
            'data' => $transactions->items(),
            'meta' => [
                'current_page' => $transactions->currentPage(),
                'last_page' => $transactions->lastPage(),
                'total' => $transactions->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $user = $request->user();
        if ($user->role !== 'pembeli') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $transaction = DB::transaction(function () use ($data, $user) {
            $product = Product::lockForUpdate()->findOrFail($data['product_id']);

            if ($product->stock < $data['quantity']) {
                abort(422, 'Stok tidak mencukupi');
            }

            $total = $product->price * $data['quantity'];

            $product->decrement('stock', $data['quantity']);

            return Transaction::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'quantity' => $data['quantity'],
                'total_price' => $total,
                'status' => 'pending',
            ]);
        });

        return response()->json($transaction, 201);
    }

    public function updateStatus(Request $request, int $id)
    {
        $user = $request->user();
        $data = $request->validate([
            'status' => 'required|in:pending,processed,done',
        ]);
        $trx = Transaction::with('product')->findOrFail($id);
        if ($user->role === 'admin') {
            // allow
        } elseif ($user->role === 'petani') {
            if ($trx->product->user_id !== $user->id) {
                return response()->json(['message' => 'Forbidden'], 403);
            }
        } else {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $trx->status = $data['status'];
        $trx->save();
        return response()->json($trx);
    }
}
