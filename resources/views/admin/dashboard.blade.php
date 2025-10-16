@extends('admin.layout')

@section('content')
  <h1 class="h3 fw-bold mb-3">Dashboard Penjualan</h1>

  <div class="row g-3 mb-4">
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2">
            <i class="fa-solid fa-box text-success"></i>
            <div>
              <div class="small text-muted">Total Produk</div>
              <div class="h5 mb-0">{{ $totalProducts }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2">
            <i class="fa-solid fa-receipt text-success"></i>
            <div>
              <div class="small text-muted">Total Transaksi</div>
              <div class="h5 mb-0">{{ $totalTransactions }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2">
            <i class="fa-solid fa-sack-dollar text-success"></i>
            <div>
              <div class="small text-muted">Total Pendapatan</div>
              <div class="h5 mb-0">Rp {{ number_format($totalRevenue,0,',','.') }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-body">
      <h5 class="card-title">Grafik Penjualan Harian</h5>
      <canvas id="salesChart" height="120"></canvas>
    </div>
  </div>
@endsection

@push('head')
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
@endpush

@push('scripts')
<script>
(async function(){
  const resp = await fetch('{{ route('admin.charts.sales') }}');
  const rows = await resp.json();
  const labels = rows.map(r => r.date);
  const data = rows.map(r => Number(r.total));
  const ctx = document.getElementById('salesChart');
  const chart = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        label: 'Total Penjualan (Rp)',
        data,
        borderColor: '#2E7D32',
        backgroundColor: 'rgba(46, 125, 50, 0.2)',
        tension: 0.2,
        fill: true,
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: { beginAtZero: true }
      }
    }
  });
})();
</script>
@endpush
