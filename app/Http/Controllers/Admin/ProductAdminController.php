<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;

class ProductAdminController extends Controller
{
    public function index(Request $request)
    {
        $q = $request->query('q');
        $stockFrom = $request->query('stock_from');
        $stockTo = $request->query('stock_to');
        $priceFrom = $request->query('price_from');
        $priceTo = $request->query('price_to');

        $query = Product::query();
        if ($q) {
            $query->where('name', 'like', "%$q%");
        }
        if ($stockFrom !== null) {
            $query->where('stock', '>=', (int)$stockFrom);
        }
        if ($stockTo !== null) {
            $query->where('stock', '<=', (int)$stockTo);
        }
        if ($priceFrom !== null) {
            $query->where('price', '>=', (float)$priceFrom);
        }
        if ($priceTo !== null) {
            $query->where('price', '<=', (float)$priceTo);
        }
        $products = $query->latest('id')->paginate(10)->withQueryString();
        return view('admin.products.index', compact('products', 'q', 'stockFrom', 'stockTo', 'priceFrom', 'priceTo'));
    }

    public function create()
    {
        $product = new Product();
        return view('admin.products.form', compact('product'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'image_url' => 'nullable|url',
        ]);
        // sementara user_id 1
        $data['user_id'] = 1;
        Product::create($data);
        return redirect()->route('admin.products.index')->with('ok', 'Produk dibuat');
    }

    public function edit(Product $product)
    {
        return view('admin.products.form', compact('product'));
    }

    public function update(Request $request, Product $product)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'image_url' => 'nullable|url',
        ]);
        $product->update($data);
        return redirect()->route('admin.products.index')->with('ok', 'Produk diperbarui');
    }

    public function destroy(Product $product)
    {
        $product->delete();
        return redirect()->route('admin.products.index')->with('ok', 'Produk dihapus');
    }
}
