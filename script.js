// Carga dinámica de imágenes desde la carpeta /assets/
const images = [
    'assets/Logo_full.png',
    'assets/ui_preview.png',
    'assets/screenshot1.png' // Ejemplo extra para la galería
];

const gallery = document.getElementById('image-gallery');

function loadGallery() {
    images.forEach(src => {
        const imgElement = document.createElement('img');
        imgElement.src = src;
        imgElement.alt = "Viper Gallery Image";
        imgElement.setAttribute('data-aos', 'fade-up');
        
        // Manejo de error
        imgElement.onerror = () => imgElement.style.display = 'none';
        
        gallery.appendChild(imgElement);
    });
}

document.addEventListener('DOMContentLoaded', loadGallery);

// Efecto de scroll para el Navbar
window.addEventListener('scroll', () => {
    const nav = document.querySelector('nav');
    if (window.scrollY > 50) {
        nav.style.background = "rgba(0, 0, 0, 0.98)";
        nav.style.boxShadow = "0 10px 30px rgba(0,0,0,0.8)";
    } else {
        nav.style.background = "transparent";
        nav.style.boxShadow = "none";
    }
});
