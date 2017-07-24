package MyCmdArgs;

use strict;
use warnings;

###########################################################################################
# Auteur      : Christian MOISE
# Nom         : MyCmdArgs.pm
# Mise a jour : 2017/07/12
# Objet       : gestion des arguments de la ligne de commande
###########################################################################################

our $_err_name_already_exists=1;
our $_err_unknow_arg=2;
our $_err_missing_value=3;
our $_err_disallowed_value=4;

# ==========================================================================================================================
sub new {
  my ($class, %args) = @_;

  my $self = {
  };

  bless $self, $class;

  return $self;
}

# ====================================================================================================
# ----- check if at leas one value matches one item of an array -----
sub _match_one {
  my ($self, $value, $p_array) = @_;

  foreach my $e (@$p_array) {
    if ($e=~m/\/i$/) {
      $e=~s/\/i$//;

      if ($e=~m/^$value$/i) { return 1; }
    }
    else {
      if ($e eq $value) { return 1; }
    }
  }

  return 0;
}

# ====================================================================================================
# ----- add arguments -----
sub add {
  my ($self, %args) = @_;

  my $name=$args{name};

  if ($self->{$name}) {
    print __PACKAGE__ ." add(): name \"$name\" already exists !\n\n";
    return $_err_name_already_exists;
  }

  $self->{$name}->{opt}=$args{opt};
  $self->{$name}->{default}=$args{default};
  $self->{$name}->{mandatory}=lc($args{mandatory} || "no");
  $self->{$name}->{flag}=lc($args{flag} || "no");
  $self->{$name}->{allow}=$args{allow} || 0;
  $self->{$name}->{disallow}=$args{disallow} || 0;

  if ($self->{$name}->{flag}      ne "yes") { $self->{$name}->{flag}="no";      }
  if ($self->{$name}->{mandatory} ne "yes") { $self->{$name}->{mandatory}="no"; }

  if ($self->{$name}->{flag} eq "yes") {
    $self->{$name}->{default}="no";
    $self->{$name}->{allow}=0;
    $self->{$name}->{disallow}=0;
  }

  if ($self->{$name}->{default}) { $self->{$name}->{mandatory}="no"; }

  my $default=$self->{$name}->{default}=$args{default} || "";
  my $p_disallow=$self->{$name}->{disallow};
  if (($default) && ($p_disallow)) {
    if ($self->_match_one($default, $p_disallow)) {
      print __PACKAGE__ ." add(): default value \"$default\" is not allowed !\n\n";
      return $_err_disallowed_value;
    }
  }
}

# ====================================================================================================
# ----- check arguments -----
sub check {
  my ($self, @ARGV) = @_;

  my $name;
  my $value;

  # ----- on balaie tous les arguments de la ligne de commande -----
  my $i=0;
  while ($ARGV[$i]) {

    # ----- si le nom de l'objet argument n'est pas defini, on cherche a l'identifier -----
    if (! $name) {
      foreach my $key (keys %{$self}) {
        my $p_opt=$self->{$key}->{opt};

        foreach my $opt (@$p_opt) {
          if ($opt eq $ARGV[$i]) {
            $name=$key;
            last;
          }
        }
      }
    }

    # ----- si le nom n'a pas ete identifie => erreur -----
    if (! $name) { return ($_err_unknow_arg, $ARGV[$i]); }

    # ----- affectation de la valeur a l'objet argument -----
    if ($self->{$name}->{flag} eq "yes") {
      $value="yes";
    }
    else {
      if (! defined($ARGV[$i+1])) { return ($_err_missing_value, $ARGV[$i]); }
      $value=$ARGV[$i+1];
      $i++;

      my $p_allow=$self->{$name}->{allow};
      if ($p_allow) {
        if (! ($self->_match_one($value, $p_allow))) { return ($_err_disallowed_value, $value); }
      }

      my $p_disallow=$self->{$name}->{disallow};
      if ($p_disallow) {
        if ($self->_match_one($value, $p_disallow)) { return ($_err_disallowed_value, $value); }
      }
    }

    $self->{$name}->{value}=$value;
    $name="";

    $i++;
  }

  foreach $name (keys %{$self}) {
    $value=$self->{$name}->{value};

    if (! defined($self->{$name}->{value})) {
      if ($self->{$name}->{mandatory} eq "yes") {
        my $p_opt=$self->{$name}->{opt};

        return ($_err_missing_value, $$p_opt[0]);
      }

      if (defined($self->{$name}->{default})) {
        $self->{$name}->{value}=$self->{$name}->{default};
      }

      $value=$self->{$name}->{value};
    }
  }

  return (0, "");
}

# ====================================================================================================
# ----- et values -----
sub value {
  my ($self, $name) = @_;

  return $self->{$name}->{value};
}

1;

