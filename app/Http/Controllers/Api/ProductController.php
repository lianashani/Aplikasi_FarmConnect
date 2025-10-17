<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $products = Product::query()
            ->where('stock', '>', 0)
            ->latest('id')
            ->paginate(20);

        return response()->json([
            'data' => $products->items(),
            'meta' => [
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
                'total' => $products->total(),
            ],
        ]);
    }

    public function show(int $id)
    {
        $product = Product::findOrFail($id);
        return response()->json($product);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role, ['admin','petani'], true)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'unit' => ['required', Rule::in(['kg','gr'])],
            'stock' => 'required|integer|min:0',
            'image_url' => 'nullable|url',
            'image' => 'nullable|image|max:2048',
        ]);
        $ownerId = $user->role === 'admin' ? ($request->input('user_id') ?: $user->id) : $user->id;
        // Handle image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('products', 'public');
            $data['image_url'] = asset('storage/'.$path);
        }
        $product = Product::create(array_merge($data, ['user_id' => $ownerId]));
        return response()->json($product, 201);
    }

    public function update(Request $request, int $id)
    {
        $user = $request->user();
        $product = Product::findOrFail($id);
        if ($user->role !== 'admin' && $product->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|required|numeric|min:0',
            'unit' => ['sometimes','required', Rule::in(['kg','gr'])],
            'stock' => 'sometimes|required|integer|min:0',
            'image_url' => 'nullable|url',
            'image' => 'nullable|image|max:2048',
        ]);
        if ($request->hasFile('image')) {
            // delete old if stored on public disk path
            if ($product->image_url && str_contains($product->image_url, '/storage/')) {
                $relative = str_replace(asset('storage/'), '', $product->image_url);
                Storage::disk('public')->delete($relative);
            }
            $path = $request->file('image')->store('products', 'public');
            $data['image_url'] = asset('storage/'.$path);
        }
        $product->update($data);
        return response()->json($product);
    }

    public function destroy(Request $request, int $id)
    {
        $user = $request->user();
        $product = Product::findOrFail($id);
        if ($user->role !== 'admin' && $product->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $product->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
