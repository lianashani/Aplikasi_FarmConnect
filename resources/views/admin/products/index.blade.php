@extends('admin.layout')

@section('content')
  <h1 class="text-2xl font-bold mb-4">Daftar Produk</h1>

  <form method="get" class="grid grid-cols-1 md:grid-cols-5 gap-3 mb-4">
    <input type="text" name="q" value="{{ $q }}" placeholder="Cari nama..." class="border rounded px-3 py-2" />
    <input type="number" name="stock_from" value="{{ $stockFrom }}" placeholder="Stok dari" class="border rounded px-3 py-2" />
    <input type="number" name="stock_to" value="{{ $stockTo }}" placeholder="Stok sampai" class="border rounded px-3 py-2" />
    <input type="number" step="0.01" name="price_from" value="{{ $priceFrom }}" placeholder="Harga dari" class="border rounded px-3 py-2" />
    <input type="number" step="0.01" name="price_to" value="{{ $priceTo }}" placeholder="Harga sampai" class="border rounded px-3 py-2" />
    <div class="md:col-span-5 flex gap-2">
      <button class="bg-green-700 text-white px-4 py-2 rounded">Filter</button>
      <a href="{{ route('admin.products.create') }}" class="bg-amber-600 text-white px-4 py-2 rounded">Tambah Produk Baru</a>
    </div>
  </form>

  <div class="overflow-x-auto bg-white rounded shadow">
    <table class="min-w-full">
      <thead>
        <tr class="bg-stone-100">
          <th class="text-left px-3 py-2">ID</th>
          <th class="text-left px-3 py-2">Nama</th>
          <th class="text-left px-3 py-2">Harga</th>
          <th class="text-left px-3 py-2">Stok</th>
          <th class="text-left px-3 py-2">Aksi</th>
        </tr>
      </thead>
      <tbody>
        @foreach ($products as $p)
          <tr class="border-t">
            <td class="px-3 py-2">{{ $p->id }}</td>
            <td class="px-3 py-2">{{ $p->name }}</td>
            <td class="px-3 py-2">Rp {{ number_format($p->price,0,',','.') }}</td>
            <td class="px-3 py-2">{{ $p->stock }}</td>
            <td class="px-3 py-2 flex gap-2">
              <a href="{{ route('admin.products.edit', $p) }}" class="text-blue-600">Edit</a>
              <form method="post" action="{{ route('admin.products.destroy', $p) }}" onsubmit="return confirm('Hapus produk ini?')">
                @csrf
                @method('delete')
                <button class="text-red-700">Hapus</button>
              </form>
            </td>
          </tr>
        @endforeach
      </tbody>
    </table>
  </div>

  <div class="mt-4">{{ $products->links() }}</div>
@endsection
