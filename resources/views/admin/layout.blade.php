<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>FarmConnect Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkfQbS5BbbZxZrS9xWq0B16xQ7vT8M2HN+1j6a6rQ73RJT8rjZcN2Pz+g==" crossorigin="anonymous" referrerpolicy="no-referrer" />
  <style>
    body { background-color: #f6f5ef; }
    .navbar { background-color: #2E7D32; }
    .btn-farm { background-color: #A1887F; color: #fff; }
    .btn-farm:hover { background-color: #8f786a; color: #fff; }
    .card, .table { background-color: #fff; }
  </style>
  @stack('head')
  </head>
<body>
  <nav class="navbar navbar-expand-lg navbar-dark mb-4">
    <div class="container">
      <a class="navbar-brand fw-bold" href="#"><i class="fa-solid fa-seedling me-2"></i>FarmConnect Admin</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbars" aria-controls="navbars" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbars">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item"><a class="nav-link" href="{{ route('admin.products.index') }}"><i class="fa-solid fa-box me-1"></i>Produk</a></li>
          <li class="nav-item"><a class="nav-link" href="{{ route('admin.dashboard') }}"><i class="fa-solid fa-chart-line me-1"></i>Dashboard</a></li>
        </ul>
        <span class="navbar-text"><i class="fa-regular fa-user me-1"></i> Admin</span>
      </div>
    </div>
  </nav>

  <main class="container mb-5">
    @if (session('ok'))
      <div class="alert alert-success">{{ session('ok') }}</div>
    @endif
    @yield('content')
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  @stack('scripts')
</body>
</html>
