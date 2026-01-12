// app/javascript/application.js (ES5 compatible)
(function () {
  var doc = document.documentElement;

  /* ===============================
     THEME (LIGHT / DARK)
     =============================== */

  var prefersDark = window.matchMedia &&
    window.matchMedia('(prefers-color-scheme: dark)').matches;

  var savedTheme = null;
  try {
    savedTheme = localStorage.getItem('theme');
  } catch (e) {}

  var theme = savedTheme || (prefersDark ? 'dark' : 'light');
  doc.setAttribute('data-theme', theme);

  window.toggleTheme = function () {
    var current = doc.getAttribute('data-theme') || 'light';
    var next = current === 'light' ? 'dark' : 'light';
    doc.setAttribute('data-theme', next);
    try {
      localStorage.setItem('theme', next);
    } catch (e) {}
  };

  /* ===============================
     HAMBURGER MENU
     =============================== */

  document.addEventListener('DOMContentLoaded', function () {
    var nav = document.getElementById('navLinks');
    var hamburger = document.getElementById('hamburger');

    if (!nav || !hamburger) return;

    hamburger.addEventListener('click', function () {
      nav.classList.toggle('open');
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        nav.classList.remove('open');
      }
    });

    document.addEventListener('click', function (e) {
      if (!nav.contains(e.target) && !hamburger.contains(e.target)) {
        nav.classList.remove('open');
      }
    });
  });

  /* ===============================
     UTILITIES (OPTIONAL)
     =============================== */

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

})();


document.addEventListener("DOMContentLoaded", () => {
  const slider = document.querySelector(".hero-slider");
  if (!slider) return;

  const slides = slider.querySelectorAll(".slide");
  const prev = slider.querySelector(".prev");
  const next = slider.querySelector(".next");

  let index = 0;
  let timer;

  /* DOTS */
  const dotsWrap = document.createElement("div");
  dotsWrap.className = "dots";
  slider.appendChild(dotsWrap);

  slides.forEach((_, i) => {
    const dot = document.createElement("button");
    if (i === 0) dot.classList.add("active");
    dot.addEventListener("click", () => goTo(i));
    dotsWrap.appendChild(dot);
  });

  const dots = dotsWrap.querySelectorAll("button");

  function show(i) {
    slides.forEach(s => s.classList.remove("is-active"));
    dots.forEach(d => d.classList.remove("active"));

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
});
