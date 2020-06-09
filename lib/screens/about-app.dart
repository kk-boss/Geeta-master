import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
          body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'Religious Supported By:',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Card(
              child: Image.asset("assets/guru.jpg", fit: BoxFit.cover),
              elevation: 5.0,
            ),
            const Text(
              'Naryan Bindu Adhikari',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Bhagavad Gita is knowledge of five basic truths and the relationship of each truth to the other: These five truths are Krishna, or God, the individual soul, the material world, action in this world, and time. The Gita lucidly explains the nature of consciousness, the self, and the universe. It is the essence of India\'s spiritual wisdom.\n\n'
                'Bhagavad Gita, is a part of the 5th Veda (written by Vedavyasa - ancient Indian saint) and Indian Epic- Mahabharata. It was narrated for the first time in the battle of Kurukshetra, Lord Krishna to Arjun.\n\n'
                'The Bhagavad Gita, also referred to as Gita, is a 700-verse Dharmic scripture that is part of the ancient Sanskrit epic Mahabharata. This scripture contains a conversation between Pandava prince Arjuna and his guide Krishna on a variety of philosophical issues.\n\n'
                'Faced with a fratricidal war, a despondent Arjuna turns to his charioteer Krishna for counsel on the battlefield. Krishna, through the course of the Bhagavad Gita, imparts to Arjuna wisdom, the path to devotion, and the doctrine of selfless action.\n\n'
                'The Bhagavad Gita upholds the essence and the philosophical tradition of the Upanishads. However, unlike the rigorous monism of the Upanishads, the Bhagavad Gita also integrates dualism and theism.\n\n'
                'Numerous commentaries have been written on the Bhagavad Gita with widely differing views on the essen- tials, beginning with Adi Sankara\'s commentary on the Bhagavad Gita in the eighth century CE. Commentators see the setting of the Bhagavad Gita in a battlefield as an allegory for the ethical and moral struggles of the human life.\n\n'
                'The Bhagavad Gita\'s call for selfless action inspired many leaders of the Indian independence movement including Mohandas Karamchand Gandhi, who referred to the Bhagavad Gita as his "spiritual dictionary".',
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}