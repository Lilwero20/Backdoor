// Active Nav Link Switcher
const sections = document.querySelectorAll("section, header");
const navLinks = document.querySelectorAll(".nav-item");

window.addEventListener("scroll", () => {
    let current = "";
    sections.forEach((section) => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 100) {
            current = section.getAttribute("id");
        }
    });

    navLinks.forEach((a) => {
        a.classList.remove("active");
        if (a.getAttribute("href") === `#${current}`) {
            a.classList.add("active");
        }
    });
});

// FAQ Accordion Logic
document.querySelectorAll('.faq-btn').forEach(button => {
    button.addEventListener('click', () => {
        const panel = button.nextElementSibling;
        const isOpen = panel.style.maxHeight;

        document.querySelectorAll('.faq-panel').forEach(p => p.style.maxHeight = null);
        document.querySelectorAll('.faq-btn span:last-child').forEach(s => s.innerText = '+');

        if (!isOpen) {
            panel.style.maxHeight = panel.scrollHeight + "px";
            button.querySelector('span:last-child').innerText = '-';
        }
    });
});

// Scroll Reveal Observer
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('reveal-visible');
        }
    });
}, { threshold: 0.1 });

document.querySelectorAll('.scroll-reveal').forEach(el => revealObserver.observe(el));

// Sticky Navbar & Shrink Effect
window.addEventListener('scroll', () => {
    const nav = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        nav.style.padding = '12px 0';
        nav.style.backgroundColor = 'rgba(7, 7, 8, 0.95)';
    } else {
        nav.style.padding = '20px 0';
        nav.style.backgroundColor = 'transparent';
    }
});
