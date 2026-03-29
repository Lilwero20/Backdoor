// Inicializar animaciones AOS
AOS.init({ duration: 1000, once: true });

// Cambio de estilo del Navbar al hacer scroll
window.addEventListener('scroll', () => {
    const nav = document.getElementById('navbar');
    if (window.scrollY > 50) {
        nav.style.background = 'rgba(5, 5, 5, 0.95)';
        nav.style.padding = '15px 0';
    } else {
        nav.style.background = 'transparent';
        nav.style.padding = '20px 0';
    }
});

// Lógica de FAQ (Acordeón)
document.querySelectorAll('.faq-question').forEach(button => {
    button.addEventListener('click', () => {
        const item = button.parentElement;
        item.classList.toggle('active');
        
        // Opcional: Cerrar otros cuando uno se abre
        document.querySelectorAll('.faq-item').forEach(other => {
            if (other !== item) other.classList.remove('active');
        });
    });
});

// Simulación de carga de galería (puedes añadir más rutas aquí)
const galleryContainer = document.getElementById('gallery');
const imgs = ['assets/ui_preview.png', 'assets/Logo_full.png'];

imgs.forEach(src => {
    const img = document.createElement('img');
    img.src = src;
    img.style.width = "100%";
    img.style.borderRadius = "12px";
    img.style.border = "1px solid rgba(255,255,255,0.1)";
    img.setAttribute('data-aos', 'fade-up');
    img.onerror = () => img.style.display = 'none'; // Ocultar si no existe
    galleryContainer.appendChild(img);
});
