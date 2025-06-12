// Custom JavaScript for your Jekyll site

document.addEventListener('DOMContentLoaded', function() {
    // Smooth scrolling for anchor links
    const links = document.querySelectorAll('a[href^="#"]');
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add "read more" functionality for long posts
    const posts = document.querySelectorAll('.post-content');
    posts.forEach(post => {
        if (post.scrollHeight > 500) {
            const readMoreBtn = document.createElement('button');
            readMoreBtn.textContent = 'Read More';
            readMoreBtn.className = 'read-more-btn';
            readMoreBtn.onclick = function() {
                post.style.maxHeight = 'none';
                this.style.display = 'none';
            };
            post.parentNode.insertBefore(readMoreBtn, post.nextSibling);
        }
    });

    // Dark mode toggle
    const toggleBtn = document.createElement('button');
    toggleBtn.textContent = '🌙';
    toggleBtn.className = 'dark-mode-toggle';
    toggleBtn.onclick = function() {
        document.body.classList.toggle('dark-mode');
        this.textContent = document.body.classList.contains('dark-mode') ? '☀️' : '🌙';
        localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
    };
    document.querySelector('.site-header').appendChild(toggleBtn);

    // Load saved dark mode preference
    if (localStorage.getItem('darkMode') === 'true') {
        document.body.classList.add('dark-mode');
        toggleBtn.textContent = '☀️';
    }
}); 