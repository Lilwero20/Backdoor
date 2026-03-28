// Inicializar AOS solo si existe
if (typeof AOS !== 'undefined') {
    AOS.init({
        duration: 1000,
        once: true
    });
}

// Control del Navbar (Efecto Glassmorphism al bajar)
window.addEventListener('scroll', () => {
    const nav = document.getElementById('navbar');
    if (window.scrollY > 50) {
        nav.style.background = 'rgba(5, 5, 5, 0.9)';
        nav.style.backdropFilter = 'blur(10px)';
        nav.style.padding = '15px 0';
    } else {
        nav.style.background = 'transparent';
        nav.style.backdropFilter = 'none';
        nav.style.padding = '20px 0';
    }
});

// Lógica del Acordeón FAQ
document.querySelectorAll('.faq-question').forEach(question => {
    question.addEventListener('click', () => {
        const item = question.parentElement;

        document.querySelectorAll('.faq-item').forEach(otherItem => {
            if (otherItem !== item) otherItem.classList.remove('active');
        });

        item.classList.toggle('active');
    });
});

// Carga Dinámica de la Galería
const galleryImages = [
    'assets/ui_preview.png',
    'assets/screenshot1.png'
];

const galleryContainer = document.getElementById('gallery');

if (galleryContainer) {
    galleryImages.forEach(src => {
        const img = document.createElement('img');
        img.src = src;
        img.alt = 'Viper Showcase';
        img.setAttribute('data-aos', 'fade-up');

        img.onerror = () => img.style.display = 'none';

        galleryContainer.appendChild(img);
    });
}
