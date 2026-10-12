'use strict';
document.getElementById('year').textContent = new Date().getFullYear();
document.getElementById('demo-button').addEventListener('click', () => {
  document.getElementById('demo-message').textContent = 'Success! Your JavaScript is working.';
});
