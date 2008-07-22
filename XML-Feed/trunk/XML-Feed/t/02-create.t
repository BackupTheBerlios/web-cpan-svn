# $Id$

use strict;
use Test::More tests => 70;
use XML::Feed;
use XML::Feed::Entry;
use XML::Feed::Content;
use DateTime;

# Number of formats:
# TEST:$nf=2;
for my $format (qw( Atom RSS )) {
    my $feed = XML::Feed->new($format);

    # TEST*$nf
    isa_ok($feed, 'XML::Feed::' . $format);

    # TEST*$nf
    like($feed->format, qr/^$format/, 'Format is correct');
    $feed->title('My Feed');

    # TEST*$nf
    is($feed->title, 'My Feed', 'feed title is correct');
    $feed->link('http://www.example.com/');

    # TEST*$nf
    is($feed->link, 'http://www.example.com/', 'feed link is correct');
    $feed->description('Wow!');

    # TEST*$nf
    is($feed->description, 'Wow!', 'feed description is correct');

    # TEST*$nf
    is($feed->tagline, 'Wow!', 'tagline works as alias');
    $feed->tagline('Again');

    # TEST*$nf
    is($feed->tagline, 'Again', 'setting via tagline works');
    $feed->language('en_US');

    # TEST*$nf
    is($feed->language, 'en_US', 'feed language is correct');
    $feed->author('Ben');

    # TEST*$nf
    is($feed->author, 'Ben', 'feed author is correct');
    $feed->copyright('Copyright 2005 Me');

    # TEST*$nf
    is($feed->copyright, 'Copyright 2005 Me', 'feed copyright is correct');
    my $now = DateTime->now;
    $feed->modified($now);

    # TEST*$nf
    isa_ok($feed->modified, 'DateTime', 'modified returns a DateTime');

    # TEST*$nf
    is($feed->modified->iso8601, $now->iso8601, 'feed modified is correct');

    $feed->generator('Movable Type');

    # TEST*$nf
    is($feed->generator, 'Movable Type', 'feed generator is correct');

    # TEST*$nf
    ok($feed->as_xml, 'as_xml returns something');

    my $entry = XML::Feed::Entry->new($format);

    # TEST*$nf
    isa_ok($entry, 'XML::Feed::Entry::' . $format);
    $entry->title('Foo Bar');

    # TEST*$nf
    is($entry->title, 'Foo Bar', 'entry title is correct');
    $entry->link('http://www.example.com/foo/bar.html');

    # TEST*$nf
    is($entry->link, 'http://www.example.com/foo/bar.html', 'entry link is correct');
    $entry->summary('This is a summary.');

    # TEST*$nf
    isa_ok($entry->summary, 'XML::Feed::Content');

    # TEST*$nf
    is($entry->summary->body, 'This is a summary.', 'entry summary is correct');
    $entry->content('This is the content.');

    # TEST*$nf
    isa_ok($entry->content, 'XML::Feed::Content');

    # TEST*$nf
    is($entry->content->type, 'text/html', 'entry content type is correct');

    # TEST*$nf
    is($entry->content->body, 'This is the content.', 'entry content body is correct');
    $entry->content(XML::Feed::Content->new({
            body => 'This is the content (again).',
            type => 'text/plain',
    }));

    # TEST*$nf
    isa_ok($entry->content, 'XML::Feed::Content');

    # TEST*$nf
    is($entry->content->body, 'This is the content (again).', 'setting with XML::Feed::Content works');
    $entry->category('Television');

    # TEST*$nf
    is($entry->category, 'Television', 'entry category is correct');
    $entry->author('Foo Baz');

    # TEST*$nf
    is($entry->author, 'Foo Baz', 'entry author is correct');
    $entry->id('foo:bar-15132');

    # TEST*$nf
    is($entry->id, 'foo:bar-15132', 'entry id is correct');
    my $dt = DateTime->now;
    $entry->issued($dt);

    # TEST*$nf
    isa_ok($entry->issued, 'DateTime');

    # TEST*$nf
    is($entry->issued->iso8601, $dt->iso8601, 'entry issued is correct');
    $entry->modified($dt);

    # TEST*$nf
    isa_ok($entry->modified, 'DateTime');

    # TEST*$nf
    is($entry->modified->iso8601, $dt->iso8601, 'entry modified is correct');

    $feed->add_entry($entry);
    my @e = $feed->entries;

    # TEST*$nf
    is(scalar @e, 1, 'One post in the feed');

    # TEST*$nf
    is($e[0]->title, 'Foo Bar', 'Correct post');

    # TEST*$nf
    is($e[0]->content->body, 'This is the content (again).', 'content is still correct');

    if ($format eq 'Atom') {
        # TEST*1
        like $feed->as_xml, qr/This is the content/;
    }

    if ($format eq 'RSS') {
        # TEST*1
        like $feed->as_xml, qr{xmlns:dcterms="http://purl.org/dc/terms/"};
    }
}
