#!/usr/bin/perl

use WWW::Mechanize;

$result = 1;

my $mech = WWW::Mechanize->new;

$admin_username = '';
$admin_password = '';

$starturl = "http://localhost:3000/";
$loginurl = "http://localhost:3000/login?return_to=%2F";
$adminurl = "http://localhost:3000/categories";

$mech->get($starturl);

@links = $mech->find_all_links( url_regex => qr/filter/ );

if ( $#links < 0 ) {
    print "Failed test - no filter link on main page\n";
    $result = 0;
} else {
    print "Passed test - filter link\n";
}

$mech->get($loginurl);
$mech->submit_form(
    form_number => 1,
    fields => {
    'user[username]' => $admin_username,
    'user[password]' => $admin_password,
    },    );

if ( $mech->success ) {
    print "Passed test - Login successful\n";
} else {
    print "Failed test - Login failed\n";
    $result = 0;
}

@links = $mech->find_all_links( url_regex => qr/bookings/ );

if (  $#links < 0 ) {
    print "Failed test - No booking links after login\n";
    $result = 0;
} else {
    $nlinks = $#links;
    $nlinks++;
    print "Passed test - $nlinks  booking links found after login\n";
}

$mech->get($adminurl);

if ( $mech->content =~ m/till kategori/ ) {
    print "Passed test - admin page reached after login\n";
} else {
    print "Failed test - no admin page reached\n";
    $result = 0;
}

if ( $result ) {
    print "All tests passed\n";
    exit 0;
} else {
    print "Some test(s) failed - please examine log\n";
    exit 1;
}

