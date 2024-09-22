import 'package:flutter/material.dart';

/*
Schedule Settings:
"Feeling Quirky. Might Delete Later" -John Daniher, 9/21/2024
Class created to manage settings of bells (i.e. Class name, color, teacher, etc.)

Hopefully, we will have a more official/automated solution in the future
 */

class ScheduleSettings {
  //Map of Maps for all bell data
  static Map bellInfo = {
    'A': {
      'location': 'Room #2549',
      'name': 'CCP IT Fundamentals',
      'teacher': 'Mr. Neal Ryan',
      'color': Colors.orange,
      'emoji': '🖥️'
    },
    'B': {
      'location': 'Room #1507',
      'name': 'Honors Precalculus BC',
      'teacher': 'Mr. George Beluan',
      'color': Colors.blueAccent,
      'emoji': '🧮'
    },
    'C': {
      'location': 'Room #2524',
      'name': 'AP English Literature',
      'teacher': 'Mrs. Elizabeth Heile',
      'color': Colors.yellow,
      'emoji': '📖'
    },
    'D': {
      'location': 'Room #1550',
      'name': 'AP Physics I',
      'teacher': 'Mrs. Jennifer Boughton',
      'color': Colors.green,
      'emoji': '🔬'
    },
    'E': {
      'location': 'Room #3189',
      'name': 'Morality and Social Justice',
      'teacher': 'Mr. Alexander Hale',
      'color': Colors.deepPurple,
      'emoji': '💭'
    },
    'F': {
      'location': null,
      'name': 'Free Bell',
      'teacher': '',
      'color': Colors.amber,
      'emoji': null
    },
    'G': {
      'location': 'Room #3524',
      'name': 'Honors Latin III',
      'teacher': 'Dr. Braden Mechley',
      'color': Colors.red,
      'emoji': '🗣️'
    },
    'H': {
      'location': 'Room #2502',
      'name': 'AP United States History',
      'teacher': 'Mrs. Jessica Dempsey',
      'color': Colors.lime,
      'emoji': '🕰️'
    },
  };
}