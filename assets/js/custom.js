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

    // Light/Dark mode toggle (Dark is now default)
    const toggleBtn = document.createElement('button');
    toggleBtn.textContent = '☀️'; // Start with sun icon since dark is default
    toggleBtn.className = 'dark-mode-toggle';
    toggleBtn.onclick = function() {
        document.body.classList.toggle('light-mode');
        this.textContent = document.body.classList.contains('light-mode') ? '🌙' : '☀️';
        localStorage.setItem('lightMode', document.body.classList.contains('light-mode'));
    };
    document.querySelector('.site-header').appendChild(toggleBtn);

    // Load saved light mode preference (dark is default now)
    if (localStorage.getItem('lightMode') === 'true') {
        document.body.classList.add('light-mode');
        toggleBtn.textContent = '🌙';
    }
}); 