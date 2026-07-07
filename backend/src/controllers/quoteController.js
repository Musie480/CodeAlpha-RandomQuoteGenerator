const db = require('../config/db');

const fallbackQuotes = [
  { id: 1, quote: 'The only way to do great work is to love what you do.', author: 'Steve Jobs', category: 'inspiration' },
  { id: 2, quote: 'In the middle of every difficulty lies opportunity.', author: 'Albert Einstein', category: 'inspiration' },
  { id: 3, quote: 'Believe you can and you\'re halfway there.', author: 'Theodore Roosevelt', category: 'inspiration' },
  { id: 4, quote: 'Success is not final, failure is not fatal: it is the courage to continue that counts.', author: 'Winston Churchill', category: 'success' },
  { id: 5, quote: 'The future belongs to those who believe in the beauty of their dreams.', author: 'Eleanor Roosevelt', category: 'inspiration' },
  { id: 6, quote: 'Life is what happens when you\'re busy making other plans.', author: 'John Lennon', category: 'life' },
  { id: 7, quote: 'The only true wisdom is in knowing you know nothing.', author: 'Socrates', category: 'wisdom' },
  { id: 8, quote: 'Creativity is intelligence having fun.', author: 'Albert Einstein', category: 'creativity' },
  { id: 9, quote: 'A friend is someone who knows all about you and still loves you.', author: 'Elbert Hubbard', category: 'friendship' },
  { id: 10, quote: 'Where there is love there is life.', author: 'Mahatma Gandhi', category: 'love' },
  { id: 11, quote: 'Two things are infinite: the universe and human stupidity; and I\'m not sure about the universe.', author: 'Albert Einstein', category: 'humor' },
];

const categories = ['inspiration', 'wisdom', 'success', 'life', 'love', 'friendship', 'creativity', 'humor'];

exports.getRandomQuote = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM quotes ORDER BY RAND() LIMIT 1');
    if (rows.length === 0) return res.json(fallbackQuotes[Math.floor(Math.random() * fallbackQuotes.length)]);
    res.json(rows[0]);
  } catch {
    res.json(fallbackQuotes[Math.floor(Math.random() * fallbackQuotes.length)]);
  }
};

exports.getQuotesByCategory = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM quotes WHERE category = ?', [req.params.category]);
    if (rows.length === 0) {
      const fallback = fallbackQuotes.filter(q => q.category === req.params.category);
      return res.json(fallback);
    }
    res.json(rows);
  } catch {
    const fallback = fallbackQuotes.filter(q => q.category === req.params.category);
    res.json(fallback);
  }
};

exports.getCategories = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT DISTINCT category FROM quotes ORDER BY category');
    const cats = rows.map(r => r.category);
    res.json(cats.length > 0 ? cats : categories);
  } catch {
    res.json(categories);
  }
};
