// ... AOS y Navbar Scroll se mantienen igual ...

// LÓGICA FAQ ACTUALIZADA
document.querySelectorAll('.faq-question').forEach(question => {
    question.addEventListener('click', () => {
        const item = question.parentElement;
        
        // Cerrar otros si se abre uno nuevo
        document.querySelectorAll('.faq-item').forEach(otherItem => {
            if (otherItem !== item) {
                otherItem.classList.remove('active');
            }
        });

        item.classList.toggle('active');
    });
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
    img.onerror = () => img.style.display = 'none';
    galleryContainer.appendChild(img);
});
