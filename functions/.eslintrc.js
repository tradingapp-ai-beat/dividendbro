module.exports = {
  env: {
    node: true, // Set the environment to Node.js
    es6: true,  // Enable ES6 features
  },
  extends: [
    'eslint:recommended',
  ],
  parserOptions: {
    ecmaVersion: 2018, // Specify ECMAScript version to 2018
  },
  rules: {
    'no-unused-vars': ['warn', { argsIgnorePattern: 'context' }],
    'no-undef': 'off', // Turn off no-undef rule for Node.js
  },
};
