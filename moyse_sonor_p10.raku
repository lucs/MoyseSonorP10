#!/usr/bin/env raku

#`((

    To compose identifier names representing musical notes:

        ñ    : 0   8   16     16    : Increases by 1 per semitone.
        ñy   : b   g'  ees''  dis'' : LilyPond representation.
        ñh   : b   g'  e♭''   d♯''  : "Human" representation.
        ñho  : b   g   e♭     d♯    : Human, no octave info.

    For example:

        my ($ñ1,   $ñ2,   $ñ3)   = ( 3, 5, 9    );
        my ($ñy1,  $ñy2,  $ñy3)  = < d' e' gis' >;
        my ($ñh1,  $ñh2,  $ñh3)  = < d' e' g♯'  >;
        my ($ñho1, $ñho2, $ñho3) = < d  e  g♯   >;

))

# --------------------------------------------------------------------
# The notes we can handle, in LilyPond representation and identified
# numerically by their array index. For example, note 7 is F♯4 or G♭4.

my @ñy = [
    [< b     ces'  >],  #  0
    [< bis   c'    >],  #  1
    [< cis'  des'  >],  #  2
    [< d'          >],  #  3
    [< dis'  ees'  >],  #  4
    [< e'    fes'  >],  #  5
    [< eis'  f'    >],  #  6
    [< fis'  ges'  >],  #  7
    [< g'          >],  #  8
    [< gis'  aes'  >],  #  9
    [< a'          >],  # 10
    [< ais'  bes'  >],  # 11
    [< b'    ces'' >],  # 12
    [< bis'  c''   >],  # 13
    [< cis'' des'' >],  # 14
];

# --------------------------------------------------------------------
# The keys are named so that alphabetically, the earlier ones have
# precedence over the later ones.

my %ñho-scales = (
        # Major.
    'maj00' => [< c  d  e  f  g  a  b  >],
    'maj1♯' => [< g  a  b  c  d  e  f♯ >],
    'maj2♯' => [< d  e  f♯ g  a  b  c♯ >],
    'maj3♯' => [< a  b  c♯ d  e  f♯ g♯ >],
    'maj4♯' => [< e  f♯ g♯ a  b  c♯ d♯ >],
    'maj5♯' => [< b  c♯ d♯ e  f♯ g♯ a♯ >],
    'maj6♯' => [< f♯ g♯ a♯ b  c♯ d♯ e♯ >],
    'maj7♯' => [< c♯ d♯ e♯ f♯ g♯ a♯ b♯ >],
    'maj1♭' => [< f  g  a  b♭ c  d  e  >],
    'maj2♭' => [< b♭ c  d  e♭ f  g  a  >],
    'maj3♭' => [< e♭ f  g  a♭ b♭ c  d  >],
    'maj4♭' => [< a♭ b♭ c  d♭ e♭ f  g  >],
    'maj5♭' => [< d♭ e♭ f  g♭ a♭ b♭ c  >],
    'maj6♭' => [< g♭ a♭ b♭ c♭ d♭ e♭ f  >],
    'maj7♭' => [< c♭ d♭ e♭ f♭ g♭ a♭ b♭ >],

        # Melodic minor.
    'min00' => [< a  b  c  d  e  f♯ g♯ >],
    'min1♯' => [< e  f♯ g  a  b  c♯ d♯ >],
    'min2♯' => [< b  c♯ d  e  f♯ g♯ a♯ >],
    'min3♯' => [< f♯ g♯ a  b  c♯ d♯ e♯ >],
    'min4♯' => [< c♯ d♯ e  f♯ g♯ a♯ b♯ >],
    'min5♯' => [< g♯ a♯ b  c♯ d♯ e♯ fD >],
    'min6♯' => [< d♯ e♯ f♯ g♯ a♯ b♯ cD >],
    'min7♯' => [< a♯ b♯ c♯ d♯ e♯ fD gD >],
    'min1♭' => [< d  e  f  g  a  b  c♯ >],
    'min2♭' => [< g  a  b♭ c  d  e  f♯ >],
    'min3♭' => [< c  d  e♭ f  g  a  b  >],
    'min4♭' => [< f  g  a♭ b♭ c  d  e  >],
    'min5♭' => [< b♭ c  d♭ e♭ f  g  a  >],
    'min6♭' => [< e♭ f  g♭ a♭ b♭ c  d  >],
    'min7♭' => [< a♭ b♭ c♭ d♭ e♭ f  g  >],

);

# --------------------------------------------------------------------
sub ñy-to-ñh ($ñy is copy) {
    do given $ñy {
        s/ 'es' /♭/;
        s/ 'is' /♯/;
    }
    return $ñy;
}

# --------------------------------------------------------------------
sub ñy-to-ñho ($ñy is copy) {
    do given $ñy {
        s/ 'es' /♭/;
        s/ 'is' /♯/;
        s:g/ \' //;
    }
    return $ñy;
}

# --------------------------------------------------------------------
# This function is used to make sure FIXME for example although ｢fes｣
# is lower than ｢eis｣, their note names ｢f｣ and ｢e｣ might suggest that
# the first is higher.

    # Some example returns:
    #   ｢0｣  given ｢bes｣ or ｢b｣
    #   ｢1｣  given ｢c'｣  or ｢cis'｣
    #   ｢15｣ given ｢c''｣ or ｢ces''｣
sub degree ($ñy) {
    state %degree-num = (
        c => 1,
        d => 2,
        e => 3,
        f => 4,
        g => 5,
        a => 6,
        b => 7,
    );
    my $letter = $ñy.substr: 0, 1;
    my $nb-quotes = +$ñy.comb: "'";
    return %degree-num{$letter} + $nb-quotes * 7;
}

# --------------------------------------------------------------------
class ÑyChord {

    has $.ñy1;
    has $.ñy2;
    has $.ñy3;

    method new ($ñy1, $ñy2, $ñy3) {
        return self.bless: :$ñy1, :$ñy2, :$ñy3;
    }

    method Str {
            # ⦃"b g♯' d♭''"⦄
        return (
            ñy-to-ñh($.ñy1),
            ñy-to-ñh($.ñy2),
            ñy-to-ñh($.ñy3),
        ).join: ' ';
    }

        # Takes the $.ñy⋯, appends '1' to the first one, to make it a
        # whole note, joins all three with spaces and wraps it up with
        # pointy brackets, to make the notes simultaneous in LilyPond.
        # An optional comment may be added.
        # ⦃"<<  fisis'1   gis'     a' >> % Hand set. 282 8.9.10\n"⦄
    method ly-chord ($comment?) {
        return sprintf "<< %8s %6s %6s >> %% %s\n",
            $.ñy1 ~ '1',
            $.ñy2,
            $.ñy3,
            $comment // "",
        ;
    }

}

# --------------------------------------------------------------------
class ÑChord {

    has $.ñ1;
    has $.ñ2;
    has $.ñ3;

    method new ($ñ1, $ñ2, $ñ3) {
        return self.bless: :$ñ1, :$ñ2, :$ñ3;
    }

        # ⦃3.5.9⦄.
    method Str {
        return ($.ñ1, $.ñ2, $.ñ3).join: '.';
    }

# --------------------------------------------------------------------
    method repr-ly ($comment) {

        sub join-comments ($comm1, $comm2) {
            return sprintf "%20s %s", $comm1, $comm2;
        }

            # After experimenting with algorithm variations that try
            # to find the best ÑyChord for a given ÑChord, the
            # following ones were found to be easier to just implement
            # by hand. See at the end of this file to see which
            # choices were available. Also included is the single
            # ÑChord that requires a double-shart (could have been a
            # double-flat).
        sub hand-set ($ñy1, $ñy2, $ñy3) {
            return ÑyChord.new(
                $ñy1, $ñy2, $ñy3
            ).ly-chord(join-comments "Hand set.", $comment)
        }

        given ($.ñ1, $.ñ2, $.ñ3) {
            when (8,  9, 10) { return hand-set "fisis'", "gis'", "a'"    }
            when (2, 12, 13) { return hand-set "des'",   "b'",   "c'"    }
            when (0, 11, 13) { return hand-set "b",      "ais'", "c''"   }
            when (0, 10, 11) { return hand-set "ces'",   "a'",   "bes'"  }
            when (3,  4, 14) { return hand-set "d'",     "ees'", "des''" }
            when (3, 13, 14) { return hand-set "d'",     "bis'", "cis''" }
            when (0,  1, 11) { return hand-set "b",      "c'",   "ais'"  }
            when (2,  3, 13) { return hand-set "cis'",   "d'",   "bis'"  }
            when (1, 12, 14) { return hand-set "c'",     "b'",   "des''" }
            when (1,  2, 12) { return hand-set "c'",     "des'", "b'"    }
            when (1, 11, 12) { return hand-set "c'",     "ais'", "b'"    }
            when (0, 13, 14) { return hand-set "b",      "c''",  "des''" }
            when (0,  2, 13) { return hand-set "b",      "des'", "c''"   }
            when (1,  3, 14) { return hand-set "bis",    "d'",   "cis''" }
            when (0,  1, 14) { return hand-set "b",      "c'",   "des''" }
        }

            # Build an array of all ÑyChord candidates that can be
            # used to represent the instance.
        my ÑyChord @lc-cand;
        for @ñy[$.ñ1].list -> $ñy1 {
            for @ñy[$.ñ2].list -> $ñy2 {
                next if degree($ñy2) <= degree($ñy1);
                for @ñy[$.ñ3].list -> $ñy3 {
                    next if degree($ñy3) <= degree($ñy2);
                    @lc-cand.push: ÑyChord.new: $ñy1, $ñy2, $ñy3;
                }
            }
        }

        # --------------------------------------------------------------------
        # Does only one representation work?

            # If a single representation works, just return it.
        return @lc-cand[0].ly-chord(
            join-comments "Only possible way.", $comment
        ) if @lc-cand.elems == 1;

        # --------------------------------------------------------------------
        # Does the chord match notes found in one of the @ñho-scale`s?

            # Holds only two values: ｢Matched scale key｣ and
            # ｢@lc-cand[matching index]｣, ⦃["m0j2♯", @lc-cand[3]]⦄.
            # The values get set or replaced when an earlier scale
            # happens to match. We initialize it to invalid values to
            # make it easier for comparisons.
        my @earliest-scale-found = ['none', Any];
      TryCand:
        for @lc-cand -> $lc-cand {
                # If the three notes are found in one of the
                # ñho-scales, from the simplest to the most complex
                # (YMMV), we have a candidate for returning.
            my $ñho1 = $lc-cand.ñy1.&ñy-to-ñho;
            my $ñho2 = $lc-cand.ñy2.&ñy-to-ñho;
            my $ñho3 = $lc-cand.ñy3.&ñy-to-ñho;
            for %ñho-scales.keys.sort -> $scale {
                if (
                    ($ñho1, $ñho2, $ñho3) (<=) %ñho-scales{$scale} &&
                    $scale lt @earliest-scale-found[0]
                ) {
                    @earliest-scale-found = [$scale, $lc-cand];
                    next TryCand;
                }
            }
        }
        if @earliest-scale-found[0] ne 'none' {
            return @earliest-scale-found[1].ly-chord(
                join-comments @earliest-scale-found[0], $comment
            );
        }

        # --------------------------------------------------------------------
        # Found no interesting representation.

            # Print to STDERR the possible representations, to
            # get ideas about what to do.
        note ~self ~ " : no representation found.";
        for ^@lc-cand.elems -> $i {
            note "    ", ~@lc-cand[$i];
        }

            # And just display a single place-holder note.
        return ÑyChord.new("a''", "", "").ly-chord(
            join-comments "No match.", $comment
        );
    }

}

# --------------------------------------------------------------------
class AllÑChords {
    has ÑChord @.chords;

    method new (
            # ⦃0⦄ and ⦃14⦄.
        $lo-ñ,
        $hi-ñ,

            # Instead of storing the ÑChord`s in @.chords starting
            # from the beginning, like ｢0.1.2, 0.1.3, 0.1.4, …｣, we
            # will start later in the sequence. Given something like
            # ⦃248⦄ when the low and high notes are ｢0｣ and ｢14｣, we
            # would start at chord ｢3.5.9｣.
        $start-at,

            # Instead of storing the ÑChord`s in @.chords in a simple
            # increasing order, ⦃3.5.9, 3.5.10, 3.5.11,  …⦄, we will
            # skip this number of elements between chords (wrapping
            # around modulo the total number of ÑChord`s) to shuffle
            # things up. Given ⦃191⦄ and again, low and high notes ｢0｣
            # and ｢14｣ and starting at ｢248｣, we would obtain ｢3.5.9,
            # 9.11.12, 2.3.10, …｣.
        $skip,

    ) {
            # Place in an array all three note combinations between
            # the low and high notes. For example, given ⦃0⦄ and ⦃14⦄,
            # the array would hold elements from going from ｢[0, 1,
            # 2], [0, 1, 3], [0, 1, 4], …｣ to ｢…, [12, 13, 14]｣.
        my @chords-in-order;
        for $lo-ñ..($hi-ñ - 2) -> $ñ1 {
            for ($ñ1 + 1)..($hi-ñ - 1) -> $ñ2 {
                for ($ñ2 + 1)..$hi-ñ -> $ñ3 {
                    @chords-in-order.push: [$ñ1, $ñ2, $ñ3];
                }
            }
        }

            # Fill up the instance's chords array starting and
            # skipping as requested.
        my @chords;
        my $i = $start-at;
        my $nb-chords = @chords-in-order.elems;
        for ^$nb-chords {
            @chords.push: ÑChord.new(|@chords-in-order[$i]);
            $i += $skip;
            $i %= $nb-chords;
        }

        return self.bless: :@chords;
    }

}

# --------------------------------------------------------------------
# Print a text version of the chords. Will look something like this:
#
#    3.5.9  9.11.12   2.3.10  5.11.13 …
#   5.6.10   0.8.13   3.7.11    0.1.3 …
#   …

multi sub MAIN ('txt') {
        # Starting at 248 will turn out to be chord [3, 5, 9].
    my AllÑChords $ATNC .= new: 0, 14, 248, 191;

        # Construct the text, making sure to be clean by stripping
        # blanks at end of lines if there are any.
    my $text;
    for ^$ATNC.chords.elems -> $i {
        $text ~= sprintf "%8s ", ~$ATNC.chords[$i];

            # Don't have too long lines.
        if ($i + 1) %% 10 {
            $text .= chop;
            $text ~= "\n";
        }
    }
    $text .= chop if $text ~~ / ' ' $/;
    print $text;
}

# --------------------------------------------------------------------
# Prints a LilyPond version of the chords.

multi sub MAIN ('ly') {
   # my AllÑChords $ATNC .= new: 5, 10, 0, 1;   # For testing.
    my AllÑChords $ATNC .= new: 0, 14, 248, 191;
    my $all-notes;
    for ^$ATNC.chords.elems -> $i {
        my $tnc = $ATNC.chords[$i];
        $all-notes ~= $tnc.repr-ly(sprintf("%3d %s", $i, ~$tnc));
    }

    my $lilypond-text = q:to/EoL/
        \version "2.22.0"

        #(set-default-paper-size "letter")
        #(set-global-staff-size 18)

        % --------------------------------------------------------------------
        \header {
            title = "Moyse, Sonorité p.10, rearranged à la ABC"
            composer = "Luc St-Louis (lucs)"
            tagline = ""
        }

        % --------------------------------------------------------------------
        \paper {
            indent = 0\in
            line-width = 8.5\in - 2.0 * 0.5\in
        }

        % --------------------------------------------------------------------
        Notes = {
        <<<NOTES>>>
        }

        % --------------------------------------------------------------------
        \score {
          \new Staff {
            \override Staff.TimeSignature #'stencil = ##f
            \key c \major
            \time 4/4
            \Notes
            \bar "|."
          }
        }
        EoL
    ;

    $lilypond-text ~~ s/ '<<<NOTES>>>' /{$all-notes}/;
    print $lilypond-text;
}

# --------------------------------------------------------------------
=finish

2.12.13 : no representation found.
    c♯' b' c''
  * d♭' b' c''
0.11.13 : no representation found.
    b a♯' b♯'
  * b a♯' c''
    b b♭' c''
    c♭' a♯' b♯'
    c♭' a♯' c''
    c♭' b♭' c''
0.10.11 : no representation found.
    b a' b♭'
  * c♭' a' b♭'
3.4.14 : no representation found.
    d' e♭' c♯''
  * d' e♭' d♭''
3.13.14 : no representation found.
  * d' b♯' c♯''
    d' b♯' d♭''
    d' c'' d♭''
0.1.11 : no representation found.
  * b c' a♯'
    b c' b♭'
2.3.13 : no representation found.
  * c♯' d' b♯'
    c♯' d' c''
1.12.14 : no representation found.
    b♯ b' c♯''
    b♯ b' d♭''
    b♯ c♭'' d♭''
    c' b' c♯''
  * c' b' d♭''
    c' c♭'' d♭''
1.2.12 : no representation found.
    b♯ c♯' b'
    b♯ c♯' c♭''
    b♯ d♭' b'
    b♯ d♭' c♭''
  * c' d♭' b'
    c' d♭' c♭''
1.11.12 : no representation found.
    b♯ a♯' b'
    b♯ a♯' c♭''
    b♯ b♭' c♭''
  * c' a♯' b'
    c' a♯' c♭''
    c' b♭' c♭''
0.13.14 : no representation found.
    b b♯' c♯''
    b b♯' d♭''
  * b c'' d♭''
    c♭' b♯' c♯''
    c♭' b♯' d♭''
    c♭' c'' d♭''
0.2.13 : no representation found.
    b c♯' b♯'
    b c♯' c''
    b d♭' b♯'
  * b d♭' c''
    c♭' d♭' b♯'
    c♭' d♭' c''
1.3.14 : no representation found.
  * b♯ d' c♯''
    b♯ d' d♭''
    c' d' c♯''
    c' d' d♭''
0.1.14 : no representation found.
    b c' c♯''
  * b c' d♭''

