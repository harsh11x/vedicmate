-- Seed data for Scriptures (Bhagavad Gita)

-- 1. Insert Scripture (Bhagavad Gita)
INSERT INTO scriptures (id, slug, title_en, title_sans, type, description, author, chapter_count)
VALUES (
    'd290f1ee-6c54-4b01-90e6-d701748f0851',
    'bhagavad-gita',
    'Bhagavad Gita',
    'श्रीमद्भगवद्गीता',
    'gita',
    'The Song of God, a 700-verse Hindu scripture that is part of the epic Mahabharata.',
    'Vyasa',
    18
) ON CONFLICT (slug) DO NOTHING;

-- 2. Insert Chapter 1
INSERT INTO scripture_chapters (id, scripture_id, chapter_number, title_en, title_sans, summary_en, verse_count)
VALUES (
    'c1000000-0000-0000-0000-000000000001',
    'd290f1ee-6c54-4b01-90e6-d701748f0851',
    1,
    'Arjuna Vishada Yoga',
    'अर्जुनविषादयोग',
    'Observing the Armies on the Battlefield of Kurukshetra. Arjuna sees his kinsmen on the battlefield and is overwhelmed by grief and compassion.',
    47
) ON CONFLICT (scripture_id, chapter_number) DO NOTHING;

-- 3. Insert Verses for Chapter 1 (Sample verses)
INSERT INTO scripture_verses (chapter_id, verse_number, text_sans, text_iast, translation_en, meaning_en)
VALUES 
(
    'c1000000-0000-0000-0000-000000000001',
    1,
    'धृतराष्ट्र उवाच |
धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |
मामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||1||',
    'dhṛtarāṣṭra uvāca
dharma-kṣetre kuru-kṣetre samavetā yuyutsavaḥ
māmakāḥ pāṇḍavāś caiva kim akurvata sañjaya',
    'Dhritarashtra said: O Sanjay, after my sons and the sons of Pandu assembled in the place of pilgrimage at Kurukshetra, desiring to fight, what did they do?',
    'dharma-kṣetre—in the field of dharma; kuru-kṣetre—in Kurukshetra; samavetāḥ—assembled; yuyutsavaḥ—desiring to fight; māmakāḥ—my party (sons); pāṇḍavāḥ—the sons of Pandu; ca—and; eva—certainly; kim—what; akurvata—did they do; sañjaya—O Sanjay.'
),
(
    'c1000000-0000-0000-0000-000000000001',
    2,
    'सञ्जय उवाच |
दृष्ट्वा तु पाण्डवानीकं व्यूढं दुर्योधनस्तदा |
आचार्यमुपसङ्गम्य राजा वचनमब्रवीत् ||2||',
    'sañjaya uvāca
dṛṣṭvā tu pāṇḍavānīkaṁ vyūḍhaṁ duryodhanas tadā
ācāryam upasaṅgamya rājā vacanam abravīt',
    'Sanjay said: On observing the Pandava army standing in military formation, King Duryodhana approached his teacher Dronacharya and spoke the following words.',
    'sañjayaḥ uvāca—Sanjay said; dṛṣṭvā—on observing; tu—but; pāṇḍava-anīkam—the Pandava army; vyūḍham—standing in a military formation; duryodhanaḥ—King Duryodhana; tadā—then; ācāryam—teacher; upasaṅgamya—approached; rājā—the king; vacanam—words; abravīt—spoke.'
),
(
    'c1000000-0000-0000-0000-000000000001',
    3,
    'पश्यैतां पाण्डुपुत्राणामाचार्य महतीं चमूम् |
व्यूढां द्रुपदपुत्रेण तव शिष्येण धीमता ||3||',
    'paśyaitāṁ pāṇḍu-putrāṇām ācārya mahatīṁ camūm
vyūḍhāṁ drupada-putreṇa tava śiṣyeṇa dhīmatā',
    'O Teacher, behold this great army of the sons of Pandu, so expertly arranged by your intelligent disciple the son of Drupada.',
    'paśya—behold; etām—this; pāṇḍu-putrāṇām—of the sons of Pandu; ācārya—O Teacher; mahatīm—great; camūm—army; vyūḍhām—arranged; drupada-putreṇa—by the son of Drupada; tava—your; śiṣyeṇa—disciple; dhīmatā—intelligent.'
)
ON CONFLICT (chapter_id, verse_number) DO NOTHING;
