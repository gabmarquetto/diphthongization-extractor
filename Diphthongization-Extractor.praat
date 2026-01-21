# Diphthongization-Extractor.psc
#
# Script developed by Gabriel Marquetto
# (Institute of Language Studies – University of Campinas, Brazil).
#
# This script computes vowel diphthongization using a two-point method.
# It outputs Euclidean Distance (Bark) and Rate of Change (Hz/ms) in F1 and F2
# between the onset (20%) and the offset (80%) of a vowel interval.
#
# The only required tier is an IntervalTier referred to as the Chunk Tier.
# Optional Word and/or Stress tiers may be provided for contextual reference.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

form File acquistion
    word audioDiretory E:/SP2010/
    word textGridDiretory textgrids/
    word outputFile data.csv
    word audioFileExtension .wav
    word desiredVowelLabel ẽ
    word malePrefix M
    word femalePrefix F
    boolean hasWordTier 0
    boolean hasStressTier 0
    integer chunkTier 2
    integer wordTier 1
    integer stressTier 4
    integer genderPrefixIndex 5
    integer maleNumberFormants 5
    integer maleFrequencyRange 5000
    integer femaleNumberFormants 5
    integer femaleFrequencyRange 5500
endform

# Grab all filenames for further iteration
Create Strings as file list: "files", audioDiretory$ + "*" + audioFileExtension$
selectObject: "Strings files"
qtFiles =  Get number of strings
for i from 1 to qtFiles
    filename$ = Get string: i
    genderPrefix$ = mid$(filename$, genderPrefixIndex, 1)
    appendInfoLine: genderPrefix$
    if genderPrefix$ != malePrefix$ and genderPrefix$ != femalePrefix$
        exitScript: "Something is wrong with gender prefixes."
    endif
    Set string: i, filename$ - audioFileExtension$
endfor

# Creates output file
writeFileLine: outputFile$, "FILE,CHUNK,WORD,STRESS,PREVIOUS,NEXT,DURATION,EUCLIDIAN.DISTANCE,F1.CHANGERATE,F2.CHANGERATE,F1.ONSET.HERTZ,F1.OFFSET.HERTZ,F2.ONSET.HERTZ,F2.OFFSET.HERTZ,F1.ONSET.BARK,F1.OFFSET.BARK,F2.ONSET.BARK,F2.OFFSET.BARK"
writeInfoLine: "Kicking off..."

# Go through input files
for i from 1 to qtFiles

    # Grab files
    selectObject: "Strings files"
    id$ = Get string: i
    Read from file: audioDiretory$ + id$ + audioFileExtension$
    Read from file: textGridDiretory$ + id$ + ".TextGrid"

    # Create Formant object
    selectObject: "Sound " + id$
    appendInfoLine: "Processing file " + id$ + "..."
    if mid$(id$, genderPrefixIndex, 1) == "M"
        To Formant (burg): 0, maleNumberFormants, maleFrequencyRange, 0.025, 50.0
    elif mid$(id$, genderPrefixIndex, 1) == "F"
        To Formant (burg): 0, femaleNumberFormants, femaleFrequencyRange, 0.025, 50.0
    endif

    # Grab Chunk Tier info
    selectObject: "TextGrid " + id$
    qtChunks = Get number of intervals: chunkTier

    # Iterate through Chunk Tier
    for chunkIndex from 1 to qtChunks

        # Grab Chunk interval info
        selectObject: "TextGrid " + id$
        chunkLabel$ = Get label of interval: chunkTier, chunkIndex 

        # Process if label corresponds to desired vowel
        if index_regex(chunkLabel$, desiredVowelLabel$)

            # Compute duration
            startTime = Get start time of interval: chunkTier, chunkIndex
            endTime = Get end time of interval: chunkTier, chunkIndex
            duration = endTime - startTime
            oneFifth = duration * 0.2
            
            # Grab word
            if hasWordTier
                wordInterval = Get interval at time: wordTier, startTime + oneFifth
                word$ = Get label of interval: wordTier, wordInterval
            else
                word$ = ""
            endif

            # Grab stress
            if hasStressTier
                stressInterval = Get interval at time: stressTier, startTime + oneFifth
                stress$ = Get label of interval: stressTier, stressInterval
            else
                stress$ = ""
            endif

            # Grab previous label
            if chunkIndex != 1
                previousLabel$ = Get label of interval: chunkTier, chunkIndex - 1
            else 
                previousLabel$ = ""
            endif

            # Grab next label
            if chunkIndex != qtChunks
                nextLabel$ = Get label of interval: chunkTier, chunkIndex + 1
            else
                nextLabel$ = ""
            endif

            # Grab Euclidian Distance and Rate Of Change
            selectObject: "Formant " + id$
            f1Onset = Get value at time: 1, startTime + oneFifth, "hertz", "linear"
            f1Offset = Get value at time: 1, endTime - oneFifth, "hertz", "linear"
            f2Onset = Get value at time: 2, startTime + oneFifth, "hertz", "linear"
            f2Offset = Get value at time: 2, endTime - oneFifth, "hertz", "linear"
            f1OnsetBark = hertzToBark(f1Onset)
            f1OffsetBark = hertzToBark(f1Offset)
            f2OnsetBark = hertzToBark(f2Onset)
            f2OffsetBark = hertzToBark(f2Offset)

            f1Leg = (f1OffsetBark - f1OnsetBark)^2
            f2Leg = (f2OffsetBark - f2OnsetBark)^2
            euclidianDistance = sqrt(f1Leg + f2Leg)

            f1ChangeRate = (f1Offset - f1Onset) / (duration * 0.6)
            f2ChangeRate = (f2Offset - f2Onset) / (duration * 0.6)

            # Save to output file
            appendFileLine: outputFile$,
                ...id$, ",",
                ...chunkLabel$, ",",
                ...word$, ",",
                ...stress$, ",",
                ...previousLabel$, ",",
                ...nextLabel$, ",",
                ...duration, ",",
                ...euclidianDistance, ",",
                ...f1ChangeRate, ",",
                ...f2ChangeRate, ",",
                ...f1Onset, ",",
                ...f1Offset, ",",
                ...f2Onset, ",",
                ...f2Offset, ",",
                ...f1OnsetBark, ",",
                ...f1OffsetBark, ",",
                ...f2OnsetBark, ",",
                ...f2OffsetBark

        endif
    endfor

    # Remove created objects
    selectObject: "TextGrid " + id$
    Remove
    selectObject: "Sound " + id$
    Remove
    selectObject: "Formant " + id$
    Remove

endfor

appendInfoLine: "We are all done!"