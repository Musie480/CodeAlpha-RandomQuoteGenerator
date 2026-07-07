const { Router } = require('express');
const {
  getRandomQuote,
  getQuotesByCategory,
  getCategories,
} = require('../controllers/quoteController');

const router = Router();

router.get('/random', getRandomQuote);
router.get('/category/:category', getQuotesByCategory);
router.get('/categories', getCategories);

module.exports = router;
