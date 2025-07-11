---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: main
---


<!-- Education Section -->
<div class="content-section">
  <h2><i class="fas fa-graduation-cap"></i> Education</h2>
  <div class="timeline">
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Master of Data Science</h3>
        <p class="timeline-meta">University of Michigan, Ann Arbor, MI | Sep 2025–Present</p>
      </div>
    </div>
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Master of Science in Computer Science</h3>
        <p class="timeline-meta">National Tsing Hua University, Hsinchu, Taiwan | Sep 2022–Jan 2025</p>
        <p><strong>Thesis:</strong> Quantum Event Identification and Simulation of Quantum Event-Learning Procedures</p>
      </div>
    </div>
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Bachelor of Science in Civil Engineering</h3>
        <p class="timeline-meta">National Cheng Kung University, Tainan, Taiwan | Sep 2018–Jun 2022</p>
      </div>
    </div>
  </div>
</div>

<!-- Experience Section -->
<div class="content-section">
  <h2><i class="fas fa-briefcase"></i> Experience</h2>
  <div class="timeline">
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Internship, QNAP</h3>
        <p class="timeline-meta">Jan 2025 – Jul 2025</p>
        <ul>
          <li>Developed a semantic search service for Jira issues using text embeddings (ChromaDB) and integrated AWS Bedrock LLM to generate resolution suggestions.</li>
          <li>Engineered an MCP server for the Jira search service, enabling developers to query issues information via coding IDE.</li>
          <li>Migrated the Konnyaku translation management website from Python 2 to Python 3 and deployed it on Kubernetes.</li>
          <li>Migrated the Device Avatar APIs service from Python to Go for improved performance and deployed it on Kubernetes; implemented token-based authentication and unit tests.</li>
          <li>Contributed to database benchmark tests comparing MongoDB and Couchbase to inform technology selection for data-intensive applications.</li>
          <li>Diagnosed and resolved a DDNS worker failure issue during RabbitMQ scaling period.</li>
          <li>Pointed out and resolved a memory leak issue in cloud product by first inspecting Grafana metric and then tracing code.</li>
          <li>Resolved NATS message production failures during AWS spot instance scaling by reconfiguring NATS server replicas.</li>
        </ul>
      </div>
    </div>
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Volunteer, US Taiwan Watch</h3>
        <p class="timeline-meta">2024</p>
        <ul>
          <li>Developed back-end features for the organization's website.</li>
        </ul>
      </div>
    </div>
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="timeline-content">
        <h3>Teaching Assistant, Linear Algebra</h3>
        <p class="timeline-meta">2023 – 2024</p>
        <ul>
          <li>Supported international students in mastering Linear Algebra concepts.</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<!-- Skills Section -->
<div class="content-section">
  <h2><i class="fas fa-cogs"></i> Skills</h2>
  <div class="skills-grid">
    <div class="skill-category">
      <h4>Languages</h4>
      <span class="skill-tag">Python</span>
      <span class="skill-tag">C++</span>
      <span class="skill-tag">Go</span>
      <span class="skill-tag">SQL</span>
      <span class="skill-tag">Bash Script</span>
      <span class="skill-tag">Verilog</span>
    </div>
    <div class="skill-category">
      <h4>Developer Tools</h4>
      <span class="skill-tag">Docker</span>
      <span class="skill-tag">Kubernetes</span>
      <span class="skill-tag">GitLab CI/CD</span>
      <span class="skill-tag">NATS</span>
      <span class="skill-tag">AWS</span>
      <span class="skill-tag">Jira</span>
      <span class="skill-tag">Sprint/Scrum</span>
    </div>
    <div class="skill-category">
      <h4>System</h4>
      <span class="skill-tag">Linux(Debian, Arch)</span>
      <span class="skill-tag">Mac</span>
      <span class="skill-tag">Windows</span>
    </div>
    <div class="skill-category">
      <h4>Database</h4>
      <span class="skill-tag">MongoDB</span>
      <span class="skill-tag">Couchbase</span>
      <span class="skill-tag">ChromaDB</span>
    </div>
  </div>
</div>

<!-- Projects Section -->
<div class="content-section">
  <h2><i class="fas fa-project-diagram"></i> Projects & Coursework</h2>
  <div class="card-grid">
    <div class="card">
      <h4>Jira-Issue-Search</h4>
      <p>Developed a semantic search service for Jira issues using text embeddings and LLM integration.</p>
      <a href="https://github.com/chyhsu/Jira-Issue-Search" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>Issue-Search-MCP</h4>
      <p>Engineered an MCP server for the Jira search service, enabling developers to query issues via coding IDE.</p>
      <a href="https://github.com/chyhsu/Issue-Search-MCP" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>File Translator</h4>
      <p>Developed a tool using LLM API to translate English PDF documents into Traditional Chinese, preserving the original format.</p>
      <a href="https://github.com/chyhsu/file_translator" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>AZtec Image Comparison</h4>
      <p>Developed a tool to compare pole figure images from AZtec software, analyzing overlapping patterns in crystallographic orientations.</p>
      <a href="https://github.com/chyhsu/AZtec-image-comparison" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>MIPS CPU Architecture [Course Work]</h4>
      <p>Constructed a MIPS CPU architecture from the ground up using Verilog.</p>
      <a href="https://github.com/chyhsu/computer-architecture" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>OS Nachos [Course Work]</h4>
      <p>Implemented and documented core OS concepts including system calls, multiprogramming, virtual memory, and file systems using the Nachos instructional OS.</p>
      <a href="https://github.com/chyhsu/OS_Nachos" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
    <div class="card">
      <h4>Advanced Compiler [Course Work]</h4>
      <p>Developed a series of compiler projects for an advanced compilers course, implementing features such as data-flow analysis and optimizations using the LLVM framework.</p>
      <a href="https://github.com/chyhsu/advanced_compiler" class="card-link" target="_blank">View on GitHub <i class="fab fa-github"></i></a>
    </div>
  </div>
</div>

<!-- Research Section -->
<div class="content-section">
  <h2><i class="fas fa-flask"></i> Research</h2>
   <div class="card-grid">
    <div class="card research-card">
      <h4><a href="/assets/pdf/arXiv_quantum_random_measurement_simulation_result.pdf" target="_blank" rel="noopener noreferrer">Quantum Event Identification and Simulation of Quantum Event-Learning Procedures</a></h4>
      <ul>
        <li> Focused on evaluating the efficiency of quantum algorithms through Python-based project simulations.</li>
        <li>Investigated the effectiveness of quantum random and blended measurements for quantum event identification.</li>
        <li>Evaluated and compared algorithms to assess their effectiveness in the quantum event identification problem.</li>
      </ul>
    </div>
  </div>
</div>
<div class="certification-section">
  <h2><i class="fas fa-certificate"></i> Certifications</h2>
  <div class="card-grid">
    <div class="card">
      <h4>Professional Certifications</h4>
      <div class="badges-container">
        <a href="https://www.credly.com/badges/5e55ce18-2865-4918-b71a-5acad5de0a0c/public_url" target="_blank">
          <img src="/assets/images/mongodb-schema-design-patterns-and-antipatterns-ski.png" alt="AWS Certified Cloud Practitioner" class="certification-badge">
        </a>
        <a href="https://www.credly.com/badges/11e30c84-8bc9-4378-bfaf-e28690606fae/public_url" target="_blank">
          <img src="/assets/images/building-rag-apps-using-mongodb.png" alt="MongoDB Certified Developer" class="certification-badge">
        </a>
        <a href="https://www.credly.com/badges/ab704694-5e2e-4dfd-bcdd-caa4f5c2c192/public_url" target="_blank">
          <img src="/assets/images/from-relational-model-sql-to-mongodb-s-document-mod.png" alt="Certified Kubernetes Administrator" class="certification-badge">
        </a>
      </div>
    </div>
  </div>
<!-- Internship Results Presentation -->
<div class="content-section">
  <h2><i class="fas fa-flask"></i> Internship Results Presentation</h2>
   <div class="card-grid">
    <div class="card research-card">
      <h4><a href="/assets/pdf/Internship Results Presentation- QNAP.pdf" target="_blank" rel="noopener noreferrer">Internship Results Presentation- QNAP</a></h4>
      <ul>
        <li>Presented the results of my internship at QNAP, a NAS Solution Provider, in Cloud Development Department.</li>
      </ul>
    </div>
  </div>
</div>