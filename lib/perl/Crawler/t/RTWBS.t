#!/usr/bin/perl

use Crawler::RTWBS;

use Crawler::CrawlerBase;

$main::debug = 3;

my $crawler = Crawler::CrawlerBase->new();

my $rtwbs = Crawler::RTWBS->new(crawler => $crawler);

$rtwbs->postProcess();

