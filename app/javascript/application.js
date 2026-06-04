(function () {
  var doc = document.documentElement;
  var escapeMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;"
  };

  var prefersDark = window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches;

  var savedTheme = null;
  try {
    savedTheme = localStorage.getItem("theme");
  } catch (e) {}

  var theme = savedTheme || (prefersDark ? "dark" : "light");
  doc.setAttribute("data-theme", theme);

  function applyTheme(nextTheme) {
    doc.setAttribute("data-theme", nextTheme);
    syncThemeToggle(nextTheme);
    try {
      localStorage.setItem("theme", nextTheme);
    } catch (e) {}
  }

  function syncThemeToggle(nextTheme) {
    var toggle = document.querySelector("[data-theme-toggle]");
    if (!toggle) return;

    toggle.setAttribute("aria-pressed", nextTheme === "dark" ? "true" : "false");
  }

  window.$qs = function (s, el) {
    return (el || document).querySelector(s);
  };

  window.$qsa = function (s, el) {
    return Array.prototype.slice.call(
      (el || document).querySelectorAll(s)
    );
  };

  window.$formatPrice = function (n) {
    try {
      return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        maximumFractionDigits: 0
      }).format(n);
    } catch (e) {
      return 'Rp ' + Math.round(n)
        .toString()
        .replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }
  };

  function escapeHtml(value) {
    return String(value || "").replace(/[&<>"']/g, function (char) {
      return escapeMap[char];
    });
  }

  function initNavigation() {
    var nav = document.getElementById("nav-links");
    var hamburger = document.getElementById("hamburger");

    if (!nav || !hamburger) return;

    hamburger.addEventListener("click", function () {
      var isOpen = nav.classList.toggle("open");
      hamburger.setAttribute("aria-expanded", isOpen ? "true" : "false");
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        nav.classList.remove("open");
        hamburger.setAttribute("aria-expanded", "false");
      }
    });

    document.addEventListener("click", function (event) {
      if (!nav.contains(event.target) && !hamburger.contains(event.target)) {
        nav.classList.remove("open");
        hamburger.setAttribute("aria-expanded", "false");
      }
    });
  }

  function initThemeToggle() {
    var toggle = document.querySelector("[data-theme-toggle]");
    if (!toggle) return;

    syncThemeToggle(doc.getAttribute("data-theme") || "light");
    toggle.addEventListener("click", function () {
      var current = doc.getAttribute("data-theme") || "light";
      applyTheme(current === "light" ? "dark" : "light");
    });
  }

  function initSlider() {
    var slider = document.querySelector(".hero-slider");
    if (!slider) return;

    var slides = slider.querySelectorAll(".slide");
    var prev = slider.querySelector(".prev");
    var next = slider.querySelector(".next");
    if (!slides.length || !prev || !next) return;

    var index = 0;
    var timer;
    var dotsWrap = document.createElement("div");
    dotsWrap.className = "dots";
    slider.appendChild(dotsWrap);

    Array.prototype.forEach.call(slides, function (_, i) {
      var dot = document.createElement("button");
      if (i === 0) dot.classList.add("active");
      dot.addEventListener("click", function () {
        goTo(i);
      });
      dotsWrap.appendChild(dot);
    });

    var dots = dotsWrap.querySelectorAll("button");

    function show(i) {
      Array.prototype.forEach.call(slides, function (slide) {
        slide.classList.remove("is-active");
      });
      Array.prototype.forEach.call(dots, function (dot) {
        dot.classList.remove("active");
      });

      slides[i].classList.add("is-active");
      dots[i].classList.add("active");
    }

    function goTo(i) {
      index = i;
      show(index);
      resetTimer();
    }

    function nextSlide() {
      index = (index + 1) % slides.length;
      show(index);
    }

    function prevSlide() {
      index = (index - 1 + slides.length) % slides.length;
      show(index);
    }

    function resetTimer() {
      clearInterval(timer);
      timer = setInterval(nextSlide, 6000);
    }

    prev.addEventListener("click", prevSlide);
    next.addEventListener("click", nextSlide);
    resetTimer();
  }

  function initMap() {
    var mapElement = document.getElementById("listing-detail-map");
    if (!mapElement || !window.L) return;

    var latitude = Number(mapElement.dataset.latitude);
    var longitude = Number(mapElement.dataset.longitude);
    if (Number.isNaN(latitude) || Number.isNaN(longitude)) return;

    var map = L.map(mapElement, { scrollWheelZoom: false }).setView([latitude, longitude], 15);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    var popupHtml =
      '<div class="map-popup">' +
      "<strong>" + escapeHtml(mapElement.dataset.title) + "</strong>" +
      "<p>" + escapeHtml(mapElement.dataset.address) + "</p>" +
      "<p>" + escapeHtml(mapElement.dataset.price) + " · " + escapeHtml(mapElement.dataset.landArea) + " m²</p>" +
      "</div>";

    L.marker([latitude, longitude]).addTo(map).bindPopup(popupHtml).openPopup();
  }

  function initStaticContactForm() {
    var form = document.querySelector("[data-static-contact-form]");
    if (!form) return;

    form.addEventListener("submit", function (event) {
      event.preventDefault();
      window.alert("Form ini masih placeholder. Sambungkan ke handler backend jika ingin dipakai.");
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initThemeToggle();
    initNavigation();
    initSlider();
    initMap();
    initStaticContactForm();
  });
})();
