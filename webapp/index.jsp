<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Boat Tours</title>
  <link rel="stylesheet" href="styles.css"/>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"/>

  <style>
    body {
      background-color: #FAF7F2;
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
    }

    .navbar {
      background-color: #003366 !important;
    }

    .navbar-brand img {
      height: 40px;
      margin-right: 10px;
    }

    .hero {
      position: relative;
      background: url('img/hero-boat.jpg') center center/cover no-repeat;
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      overflow: hidden;
    }

    .hero::before {
      content: "";
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
      z-index: 0;
    }

    .hero-content {
      z-index: 1;
      text-align: center;
      animation: fadeIn 2s ease;
    }

    .hero h1 {
      font-size: 3.5rem;
      font-weight: bold;
      margin-bottom: 20px;
    }

    .hero p {
      font-size: 1.5rem;
      margin-bottom: 30px;
    }

    .hero .btn {
      padding: 12px 28px;
      font-size: 1.1rem;
      border-radius: 30px;
    }

    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(40px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .card-title i {
      font-size: 1.2rem;
    }

    @media (max-width: 768px) {
      .hero h1 {
        font-size: 2.2rem;
      }
      .hero p {
        font-size: 1.1rem;
      }
    }
  </style>
</head>
<body>
  <nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
      <a class="navbar-brand" href="#">
        <img src="img/boatlogo.png" alt="Logo" /> My Boat Tours
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
          <li class="nav-item"><a class="nav-link" href="register.jsp">Register</a></li>
          <li class="nav-item"><a class="nav-link" href="user_dashboard.jsp">Bookings</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <section class="hero">
    <div class="hero-content container">
      <h1>Unleash Your Inner Explorer</h1>
      <p>Hop aboard and cruise through stunning coastlines. Adventure starts here.</p>
      <a href="register.jsp" class="btn btn-light me-3">Book Now</a>
      <a href="#about" class="btn btn-outline-light">Learn More</a>
    </div>
  </section>

  <!-- Enhanced Responsive Container Section -->
  <div class="container my-5">
    <div class="row g-4">
      <div class="col-lg-6 d-flex">
        <div class="card border-0 shadow-sm w-100 bg-white rounded-4 animate__animated animate__fadeInUp">
          <div class="card-body p-4">
            <h3 class="card-title text-primary mb-3">
              <i class="bi bi-info-circle-fill me-2"></i>About Us
            </h3>
            <p class="card-text">
              Welcome to the <strong>Online Boat Reservation System</strong>. We provide top-notch motorboat rentals in Palompon Leyte, perfect for your island tours and adventures. Booking is seamless and simple – just a few clicks to explore the scenic beauty of our waters.
            </p>
          </div>
        </div>
      </div>
      <div class="col-lg-6 d-flex">
        <div class="card border-0 shadow-sm w-100 bg-white rounded-4 animate__animated animate__fadeInUp animate__delay-1s">
          <div class="card-body p-4">
            <h3 class="card-title text-success mb-3">
              <i class="bi bi-telephone-fill me-2"></i>Contact Us
            </h3>
            <p class="card-text">For booking and inquiries, please contact us at:</p>
            <p class="mb-1"><strong>Mathew John</strong></p>
            <p class="mb-1"><i class="bi bi-envelope-fill me-2"></i>mathew@ourmail.com</p>
            <p><i class="bi bi-phone-fill me-2"></i>+9876543210</p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Animate.css for fade effects -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
</body>
</html>
