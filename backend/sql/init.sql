CREATE DATABASE IF NOT EXISTS quotes;
USE quotes;

CREATE TABLE IF NOT EXISTS quotes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  quote TEXT NOT NULL,
  author VARCHAR(255) DEFAULT 'Unknown',
  category VARCHAR(100) DEFAULT 'general'
);

INSERT INTO quotes (quote, author, category) VALUES
('The only way to do great work is to love what you do.', 'Steve Jobs', 'inspiration'),
('In the middle of every difficulty lies opportunity.', 'Albert Einstein', 'inspiration'),
('Believe you can and you''re halfway there.', 'Theodore Roosevelt', 'inspiration'),
('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', 'inspiration'),
('It does not matter how slowly you go as long as you do not stop.', 'Confucius', 'wisdom'),
('The only true wisdom is in knowing you know nothing.', 'Socrates', 'wisdom'),
('The unexamined life is not worth living.', 'Socrates', 'wisdom'),
('Knowing yourself is the beginning of all wisdom.', 'Aristotle', 'wisdom'),
('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', 'success'),
('The secret of success is to know something nobody else knows.', 'Aristotle Onassis', 'success'),
('Success usually comes to those who are too busy to be looking for it.', 'Henry David Thoreau', 'success'),
('The way to get started is to quit talking and begin doing.', 'Walt Disney', 'success'),
('In the end, it''s not the years in your life that count. It''s the life in your years.', 'Abraham Lincoln', 'life'),
('Life is what happens when you''re busy making other plans.', 'John Lennon', 'life'),
('The purpose of our lives is to be happy.', 'Dalai Lama', 'life'),
('Get busy living or get busy dying.', 'Stephen King', 'life'),
('Where there is love there is life.', 'Mahatma Gandhi', 'love'),
('The best thing to hold onto in life is each other.', 'Audrey Hepburn', 'love'),
('Love all, trust a few, do wrong to none.', 'William Shakespeare', 'love'),
('Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.', 'Lao Tzu', 'love'),
('A friend is someone who knows all about you and still loves you.', 'Elbert Hubbard', 'friendship'),
('Friendship is born at that moment when one person says to another: "What! You too? I thought I was the only one."', 'C.S. Lewis', 'friendship'),
('True friendship comes when the silence between two people is comfortable.', 'David Tyson', 'friendship'),
('Creativity is intelligence having fun.', 'Albert Einstein', 'creativity'),
('Creativity takes courage.', 'Henri Matisse', 'creativity'),
('Every child is an artist. The problem is how to remain an artist once he grows up.', 'Pablo Picasso', 'creativity'),
('The chief enemy of creativity is good sense.', 'Pablo Picasso', 'creativity'),
('Life is too short to be serious all the time. So, if you can''t laugh at yourself, call me!', 'Unknown', 'humor'),
('I''m not lazy, I''m on energy-saving mode.', 'Unknown', 'humor'),
('I put the "pro" in procrastination.', 'Unknown', 'humor'),
('The elevator to success is out of order. You''ll have to use the stairs... one step at a time.', 'Joe Girard', 'humor'),
('Two things are infinite: the universe and human stupidity; and I''m not sure about the universe.', 'Albert Einstein', 'humor');
