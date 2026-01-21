Diphthongization-Extractor.psc

Script developed by Gabriel Marquetto
(Institute of Language Studies – University of Campinas, Brazil)

This Praat script computes vowel diphthongization using a two-point method.
It outputs Euclidean Distance (in Bark) and Rate of Change (in Hz/ms) for F1 and F2,
measured between the onset (20%) and the offset (80%) of a vowel interval.

Required parameters:

The following parameters are mandatory:
- Audio directory
- TextGrid directory (may be the same as the audio directory)
- Chunk tier number (the tier containing the vowel or phoneme intervals)
- Target vowel(s) to be analyzed

To analyze more than one vowel, multiple targets can be specified using the
vertical bar (|), for example: a|e|i

Optional parameters:

Because the script performs formant tracking, it allows different formant
settings for male and female speakers.

- Different formant parameters may be specified by sex
- A filename prefix may be used to identify speaker sex
- This functionality is optional and can be disabled in the form interface

The parameter sexIndex specifies the position of the sex prefix in the filename.
For example, sexIndex = 1 indicates that filenames begin with the sex prefix.

Word and Stress tiers may also be provided to encode phonetic or context.
These tiers are optional; when disabled, female parameter settings are used by default.

If you use this script, please cite:

Marquetto, G. (2025). Diphthongization-Extractor.psc [Praat script]. Institute of Language Studies, University of Campinas. Available at: https://github.com/gabmarquetto/diphthongization-extractor

Contact:
For questions or comments, please contact me through marquettog@gmail.com.
