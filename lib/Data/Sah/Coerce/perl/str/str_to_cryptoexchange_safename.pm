package Data::Sah::Coerce::perl::str::str_to_cryptoexchange_safename;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 2,
        enable_by_default => 0,
        might_die => 1,
        prio => 50,
        precludes => [qr/\Astr_to_cryptoexchange_(.+)?\z/],
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"CryptoExchange::Catalog"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$cat = CryptoExchange::Catalog->new; my \@data = \$cat->all_data; ",
        "my \$lc = lc($dt); my \$rec; for (\@data) { if (defined(\$_->{code}) && \$lc eq lc(\$_->{code}) || \$lc eq lc(\$_->{name}) || \$lc eq \$_->{safename}) { \$rec = \$_; last } } ",
        "unless (\$rec) { die 'Unknown cryptoexchange code/name/safename: ' . \$lc } ",
        "\$rec->{safename} }",
    );

    $res;
}

1;
# ABSTRACT: Coerce string containing cryptoexchange code/name/safename to safename

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["str", "x.perl.coerce_rules"=>["str_to_cryptoexchange_safename"]]
