// Inicializar animaciones AOS
AOS.init({ duration: 1000, once: true });

// Cambio de estilo del Navbar al hacer scroll
window.addEventListener('scroll', () => {
    const nav = document.getElementById('navbar');
    if (window.scrollY > 50) {
        nav.style.background = 'rgba(5, 5, 5, 0.95)';
        nav.style.padding = '15px 0';
        nav.style.borderBottom = '1px solid rgba(191, 0, 255, 0.2)';
    } else {
        nav.style.background = 'transparent';
        nav.style.padding = '20px 0';
        nav.style.borderBottom = 'none';
    }
});

// Lógica de FAQ (Acordeón)
document.querySelectorAll('.faq-question').forEach(button => {
    button.addEventListener('click', () => {
        const item = button.parentElement;
        item.classList.toggle('active');
        
        document.querySelectorAll('.faq-item').forEach(other => {
            if (other !== item) other.classList.remove('active');
        });
    });
});

// Carga de imágenes en la galería
const galleryContainer = document.getElementById('gallery');
// He añadido más repeticiones para que veas el efecto de red de imágenes pequeñas
const imgs = [
    'assets/ui_preview.png', 
    'assets/screenshot1.png',
    'assets/ui_preview.png',
    'assets/ui_preview.png',
    'assets/ui_preview.png',
    'assets/ui_preview.png'
];

if (galleryContainer) {
    imgs.forEach(src => {
        const img = document.createElement('img');
        img.src = src;
        img.setAttribute('data-aos', 'fade-up');
        img.onerror = () => img.style.display = 'none';
        galleryContainer.appendChild(img);
    });
}
