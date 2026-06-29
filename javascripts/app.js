/*
   app.js
   Dynamic canvas particle simulation, scroll animations, and UI helpers
   for Dr. Robert Garrett's Portfolio website
*/

document.addEventListener('DOMContentLoaded', () => {
    initCanvas();
    initScrollAnimations();
    initMobileMenu();
    initActiveNavHighlight();
});

// Canvas Particle Mesh Simulation
function initCanvas() {
    const canvas = document.getElementById('bg-canvas');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    let width = canvas.width = window.innerWidth;
    let height = canvas.height = window.innerHeight;
    
    let particles = [];
    const particleCount = Math.min(80, Math.floor((width * height) / 15000)); // Responsive count
    const connectionDist = 120;
    
    // Mouse interaction state
    const mouse = {
        x: null,
        y: null,
        radius: 150
    };
    
    window.addEventListener('mousemove', (e) => {
        mouse.x = e.clientX;
        mouse.y = e.clientY;
    });
    
    window.addEventListener('mouseout', () => {
        mouse.x = null;
        mouse.y = null;
    });
    
    window.addEventListener('resize', () => {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
    });
    
    class Particle {
        constructor() {
            this.x = Math.random() * width;
            this.y = Math.random() * height;
            this.vx = (Math.random() - 0.5) * 0.4;
            this.vy = (Math.random() - 0.5) * 0.4;
            this.radius = Math.random() * 2 + 1;
            // Palette matches the theme (teal / blue / indigo)
            const colors = ['rgba(13, 148, 136, 0.4)', 'rgba(59, 130, 246, 0.3)', 'rgba(99, 102, 241, 0.3)'];
            this.color = colors[Math.floor(Math.random() * colors.length)];
        }
        
        update() {
            this.x += this.vx;
            this.y += this.vy;
            
            // Boundary checks
            if (this.x < 0 || this.x > width) this.vx *= -1;
            if (this.y < 0 || this.y > height) this.vy *= -1;
            
            // Mouse repeller interaction
            if (mouse.x !== null && mouse.y !== null) {
                const dx = this.x - mouse.x;
                const dy = this.y - mouse.y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < mouse.radius) {
                    const force = (mouse.radius - dist) / mouse.radius;
                    const angle = Math.atan2(dy, dx);
                    // Push particles away gently
                    this.x += Math.cos(angle) * force * 1.5;
                    this.y += Math.sin(angle) * force * 1.5;
                }
            }
        }
        
        draw() {
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
            ctx.fillStyle = this.color;
            ctx.fill();
        }
    }
    
    // Create particles
    for (let i = 0; i < particleCount; i++) {
        particles.push(new Particle());
    }
    
    // Draw lines between close particles
    function connect() {
        for (let i = 0; i < particles.length; i++) {
            for (let j = i + 1; j < particles.length; j++) {
                const dx = particles[i].x - particles[j].x;
                const dy = particles[i].y - particles[j].y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                
                if (dist < connectionDist) {
                    // Alpha gets lower as they drift apart
                    const alpha = (1 - dist / connectionDist) * 0.12;
                    ctx.strokeStyle = `rgba(13, 148, 136, ${alpha})`;
                    ctx.lineWidth = 1;
                    ctx.beginPath();
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                }
            }
        }
    }
    
    let isTabActive = true;
    document.addEventListener('visibilitychange', () => {
        isTabActive = !document.hidden;
    });
    
    function animate() {
        if (isTabActive) {
            ctx.clearRect(0, 0, width, height);
            
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            
            connect();
        }
        requestAnimationFrame(animate);
    }
    
    animate();
}

// Scroll Intersection Observer for fading sections in
function initScrollAnimations() {
    const fadeSections = document.querySelectorAll('.fade-in-section');
    
    const observerOptions = {
        root: null, // Viewport
        threshold: 0.15, // Trigger when 15% is visible
        rootMargin: "0px 0px -50px 0px"
    };
    
    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                // Optional: Stop observing once anim triggers
                // observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    fadeSections.forEach(section => {
        observer.observe(section);
    });
    
    // Header scrolled state
    const header = document.querySelector('header');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });
}

// Mobile Hamburger Menu toggle
function initMobileMenu() {
    const menuBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');
    
    if (!menuBtn || !navLinks) return;
    
    menuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('mobile-active');
        // Toggle hamburger icon
        const icon = menuBtn.querySelector('i');
        if (icon) {
            if (icon.classList.contains('fa-bars')) {
                icon.classList.replace('fa-bars', 'fa-times');
            } else {
                icon.classList.replace('fa-times', 'fa-bars');
            }
        }
    });
    
    // Close menu when clicking a link
    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('mobile-active');
            const icon = menuBtn.querySelector('i');
            if (icon) icon.classList.replace('fa-times', 'fa-bars');
        });
    });
}

// Highlight Active Section Nav Link
function initActiveNavHighlight() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-links a');
    
    window.addEventListener('scroll', () => {
        let currentSectionId = '';
        const scrollPosition = window.scrollY + 120; // Offset for sticky header
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.offsetHeight;
            
            if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
                currentSectionId = section.getAttribute('id');
            }
        });
        
        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
            }
        });
    });
}
