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
        if (!$user) {
            $user = User::first();
            if (!$user) {
                return response()->json(['data' => [], 'meta' => ['current_page' => 1, 'last_page' => 1, 'total' => 0]], 200);
            }
        }
        $transactions = Transaction::with('product')
            ->where('buyer_id', $user->id)
            ->latest('id')
            ->paginate(20);

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
        if (!$user) {
            $user = User::first();
            if (!$user) {
                return response()->json(['message' => 'Tidak ada user terdaftar untuk transaksi'], 422);
            }
        }

        $transaction = DB::transaction(function () use ($data, $user) {
            $product = Product::lockForUpdate()->findOrFail($data['product_id']);

            if ($product->stock < $data['quantity']) {
                abort(422, 'Stok tidak mencukupi');
            }

            $total = $product->price * $data['quantity'];

            $product->decrement('stock', $data['quantity']);

            return Transaction::create([
                'buyer_id' => $user->id,
                'product_id' => $product->id,
                'quantity' => $data['quantity'],
                'total_price' => $total,
                'status' => 'pending',
            ]);
        });

        return response()->json($transaction, 201);
    }
}
