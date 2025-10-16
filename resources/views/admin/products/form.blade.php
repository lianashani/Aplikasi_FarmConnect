@extends('admin.layout')

@section('content')
  <h1 class="text-2xl font-bold mb-4">{{ $product->exists ? 'Edit' : 'Tambah' }} Produk</h1>
  <form method="post" action="{{ $product->exists ? route('admin.products.update', $product) : route('admin.products.store') }}" class="space-y-3">
    @csrf
    @if($product->exists) @method('put') @endif
    <div>
      <label class="block mb-1">Nama</label>
      <input name="name" value="{{ old('name', $product->name) }}" class="border rounded px-3 py-2 w-full" required />
    </div>
    <div>
      <label class="block mb-1">Deskripsi</label>
      <textarea name="description" class="border rounded px-3 py-2 w-full" rows="3">{{ old('description', $product->description) }}</textarea>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
      <div>
        <label class="block mb-1">Harga</label>
        <input type="number" step="0.01" name="price" value="{{ old('price', $product->price) }}" class="border rounded px-3 py-2 w-full" required />
      </div>
      <div>
        <label class="block mb-1">Stok</label>
        <input type="number" name="stock" value="{{ old('stock', $product->stock) }}" class="border rounded px-3 py-2 w-full" required />
      </div>
      <div>
        <label class="block mb-1">Gambar (URL)</label>
        <input type="url" name="image_url" value="{{ old('image_url', $product->image_url) }}" class="border rounded px-3 py-2 w-full" />
      </div>
    </div>
    <div class="flex gap-2">
      <button class="bg-green-700 text-white px-4 py-2 rounded">Simpan</button>
      <a href="{{ route('admin.products.index') }}" class="px-4 py-2 border rounded">Batal</a>
    </div>
  </form>
@endsection
