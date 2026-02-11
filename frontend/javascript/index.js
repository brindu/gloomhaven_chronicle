import "$styles/index.scss"
import "$styles/syntax-highlighting.css"

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}"

// Mobile nav toggle
const toggle = document.querySelector(".nav-toggle")
if (toggle) {
  const navLinks = document.querySelector(".nav-links")
  toggle.addEventListener("click", () => {
    const open = navLinks.classList.toggle("open")
    toggle.classList.toggle("open", open)
    toggle.setAttribute("aria-expanded", open)
  })

  // Close menu when a link is tapped
  navLinks.querySelectorAll("a").forEach(link => {
    link.addEventListener("click", () => {
      navLinks.classList.remove("open")
      toggle.classList.remove("open")
      toggle.setAttribute("aria-expanded", false)
    })
  })
}
