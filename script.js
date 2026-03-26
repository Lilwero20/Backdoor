// Inicializar AOS
AOS.init({
    duration: 1000,
    once: true
});

// Cambiar estilo de Navbar al hacer Scroll
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

// Carga de imágenes en la galería
const galleryImages = [
    'assets/ui_preview.png',
    'assets/Logo_full.png',
    'assets/screenshot2.png'
];

const galleryContainer = document.getElementById('gallery');

galleryImages.forEach(src => {
    const img = document.createElement('img');
    img.src = src;
    img.alt = "Viper Showcase";
    img.setAttribute('data-aos', 'fade-up');
    
    // Manejo de errores si la imagen no existe
    img.onerror = () => img.style.display = 'none';
    
    galleryContainer.appendChild(img);
});
