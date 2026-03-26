// Carga dinámica de imágenes desde la carpeta /assets/
// Nota: En un entorno de servidor estático, necesitarás listar los nombres manualmente
const images = [
    'assets/screenshot1.png',
    'assets/screenshot2.png',
    'assets/logo_full.png',
    'assets/ui_preview.png'
];

const gallery = document.getElementById('image-gallery');

function loadGallery() {
    images.forEach(src => {
        const imgElement = document.createElement('img');
        imgElement.src = src;
        imgElement.alt = "Viper Showcase";
        imgElement.setAttribute('data-aos', 'fade-up');
        
        // Manejo de error por si la imagen no existe
        imgElement.onerror = () => imgElement.style.display = 'none';
        
        gallery.appendChild(imgElement);
    });
}

document.addEventListener('DOMContentLoaded', loadGallery);

// Efecto de scroll para el Navbar
window.addEventListener('scroll', () => {
    const nav = document.querySelector('nav');
    if (window.scrollY > 50) {
        nav.style.background = "rgba(8, 8, 8, 0.95)";
    } else {
        nav.style.background = "transparent";
    }
});
