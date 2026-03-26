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

// --- LÓGICA FAQ (Acordeón) ---
document.querySelectorAll('.faq-question').forEach(question => {
    question.addEventListener('click', () => {
        const item = question.parentElement;
        
        // Cerrar otros si quieres que solo haya uno abierto a la vez
        document.querySelectorAll('.faq-item').forEach(otherItem => {
            if (otherItem !== item) otherItem.classList.remove('active');
        });

        item.classList.toggle('active');
    });
});

// Carga de imágenes en la galería
const galleryImages = [
    'assets/ui_preview.png',
    'assets/Logo_full.png', // Opcional, puedes quitarla si no quieres el logo aquí
    'assets/screenshot2.png'
];

const galleryContainer = document.getElementById('gallery');

galleryImages.forEach(src => {
    const img = document.createElement('img');
    img.src = src;
    img.alt = "Viper Showcase";
    img.setAttribute('data-aos', 'fade-up');
    
    img.onerror = () => img.style.display = 'none';
    
    galleryContainer.appendChild(img);
});
