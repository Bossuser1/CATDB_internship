package SQLCHIPS;

# Librairie permettant de faire les requetes SQL sur la base PG.
use DBI;
use strict;
use Carp;

## Methode de connection a la base de donnees
## Parametres : Nom de user, Mot de passe, Nom de la base ( defaut : FLAGDB )
sub connect {
  my $user   = shift;
	my $passwd = shift;
	my $dbName = shift;

	# DBI
	# Si l'on a pas de dbName on met le defaut
	if ( !defined($dbName) ) {
		$dbName = $SQLCHIPS::dbName;
	}

	# Deconnection de la base si deja connecte!
	if ( defined($SQLCHIPS::dbh) ) {
		$SQLCHIPS::dbh->disconnect;
	}

	# connection
	$SQLCHIPS::dbh =
		DBI->connect( "dbi:Pg:dbname=$dbName;host=$SQLCHIPS::SERVER;port=$SQLCHIPS::PORT",
									$user, $passwd, { PrintError => 0, AutoCommit => 0 } );
	unless ($SQLCHIPS::dbh) {
		print "<H1>Unable to connect to database $dbName ($DBI::errstr)\nTests skiped.\n</H1>";
		#print "1..0\n";
		exit 0;
	}
}

# Connection to the database.
BEGIN {
	# valable quelque soit la machine
	# USER/PASSWD
	$SQLCHIPS::dbName     = 'CATDB';
	$SQLCHIPS::dbuser     = 'uselect';
	$SQLCHIPS::dbpasswd   = 'seloct06';
	$SQLCHIPS::schemaBase = "chips_tmp";

	# le serveur change suivant la machine
	# on va chercher la base sur la bonne machine
	$SQLCHIPS::SERVER = "";
	if ( !defined $ENV{'HOST'} ) {
		if ( defined $ENV{'HOSTNAME'} ) {
			$ENV{'HOST'} = $ENV{'HOSTNAME'};
		} elsif ( defined $ENV{'SERVER_NAME'} ) {
			$ENV{'HOST'} = $ENV{'SERVER_NAME'};
		} else {
			$ENV{'HOST'} = '';    # rien et pb a la connection
		}
	}

	# port par defaut
	$SQLCHIPS::PORT = "1521";
	if ( $ENV{'HOST'} =~ /jacob/ ) {
		# pour jacob
			$SQLCHIPS::SERVER="dayhoff.ips2.u-psud.fr";
 			#$SQLCHIPS::SERVER="129.175.189.28";
	} else {
		# pour les autres (gregor, ohno, urgv, blast0x, etc.)
			$SQLCHIPS::SERVER="dayhoff.ips2.u-psud.fr";
 			#$SQLCHIPS::SERVER="129.175.189.28";	
	}
	
		
	&connect( $SQLCHIPS::dbuser, $SQLCHIPS::dbpasswd, $SQLCHIPS::dbName );
}

# Method that request the db.
sub do_sql( ) {
	my $query = shift;
	if ( defined($SQLCHIPS::DEBUG) ) {
		print STDERR $query . "\n";
	}
	my $Requete = {};
	$Requete->{ORDER}     = $query;
	$Requete->{NB_COL}    = 0;
	$Requete->{NB_LINE}   = 0;
	$Requete->{LINES}     = [ [] ];
	$Requete->{COL_NAMES} = [];
	
	unless ($query) {
		die("Sql command without any query");
	}

	$SQLCHIPS::dbh->{AutoCommit} = 0;
	my $sth = $SQLCHIPS::dbh->prepare($query);
	if ( !defined( $SQLCHIPS::dbh->err ) ) {
		my $Lines = undef;
		if ( $sth->execute ) {
			$Requete->{NB_COL} = $sth->{NUM_OF_FIELDS};    # Nb fields
			if ( $query =~ /^SELECT/i ) {
				my (@data);
				$Lines = 0;
				my $type;
				while ( @data = $sth->fetchrow_array() )     ## Get all the lines
				{
					for ( $type = 0 ; $type < $sth->{NUM_OF_FIELDS} ; $type++ ) {

						# si nous avons un LOB (BLOB/CLOB)
						if ( $sth->{pg_type}->[$type] eq "oid" ) {
							my $lobjId = $data[$type];
							my $blob;

							# Lecture complete du lob
							$blob = $sth->blob_read( $lobjId, 0, 0 );
							if ( !defined($blob) ) { $blob = ""; }
							$data[$type] = $blob;
						}
					}
					$Requete->{LINES}[ $Lines++ ] = [@data];
				}

				# Recuperation des noms de colonnes
				for ( my $k = 0 ; $k < $sth->{NUM_OF_FIELDS} ; $k++ ) {
					$Requete->{COL_NAMES}[$k] = $sth->{NAME_uc}->[$k];
				}
#			} else {
#				$SQLCHIPS::dbh->commit;
			}
			$sth->finish;
			$Requete->{NB_LINE} = $Lines;
		} else {
			sqlError($Requete);
		}
	} else {
		sqlError($Requete);
	}
	return $Requete;
}

sub get_col () {    # recuperer chaque colonne de la requete
	my ( $Req, $Col ) = @_;
	my @TABLE = ();
	my $i;
	for ( $i = 0 ; $i < $Req->{NB_LINE} ; $i++ ) {
		push( @TABLE, $Req->{LINES}[$i][$Col] );
	}
	return (@TABLE);
}

sub sqlError {
	my $req = shift;
	$req->{ERR}    = $SQLCHIPS::dbh->err;
	$req->{ERRSTR} = $SQLCHIPS::dbh->errstr;

	# Commit important pour que la transaction ne reste pas bloquée
	# en cas d'erreur dans la requête
	#print "<H4>##".$req->{ORDER}."</H4>##<H3>".$req->{ERRSTR}."##</H3>\n";
	$SQLCHIPS::dbh->rollback;
}

# Deconnection de la base.
END {
	$SQLCHIPS::dbh->disconnect;
}

1;
