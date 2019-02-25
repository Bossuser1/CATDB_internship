#requete sql pour faire histogrammes species/projects
# attention prendre que les données publques
# 4 fev 2019
select count(*) from project where is_public='yes';
 count 
-------
   349
# project_id in (select project_id from project where is_public='yes')

# table organism
----------------
select * from organism order by organism_name;

# --> donne 45 lignes mais avec quelque fois que le genre ou wheat à
# --> la place de triticum

# table sample_source
---------------------

# nbr d'espèces par rapport aux nombre de projets

select o.organism_name, count(distinct ss.project_id) from sample_source ss, organism o where ss.project_id in (select project_id from project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name;
-----------------------------------+-------
 Alopecurus myosuroides            	     1
 Arabidopsis thaliana              	   276
 Brachypodium                      	     1
 Brassica                          	     1
 Brassica napus                    	     3
 Gallus gallus                     	     2
 Gossypium                         	     1
 Helianthus                        	     4
 Helianthus annuus                 	     2
 Homo sapiens                      	     1
 Maize                             	     1
 Medicago sativa                   	     1
 Medicago truncatula               	    18
 Oryza sativa                      	     7
 Physcomitrella patens             	     1
 Pisum sativum L                   	     3
 Populus deltoides x Populus nigra 	     5
 Populus tremula x Populus alba    	     5
 Rosa chinensis                    	     2
 Rosa gallica                      	     1
 Rosa hybrida                      	     3
 Rosa wichurana                    	     1
 Solanum lycopersicum              	     1
 Thellungiella                     	     1
 Triticum aestivum                 	     2
 Vitis vinifera                    	     2
 Zea mays                          	     7
(27 rows)


# par rapport aux nbr d'experiment

select o.organism_name, count(distinct ss.experiment_id) from sample_source ss, organism o where ss.project_id in (select project_id from project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name;

          organism_name           	 count 
-----------------------------------+-------
 Alopecurus myosuroides            	     1
 Arabidopsis thaliana              	   360
 Brachypodium                      	     1
 Brassica                          	     1
 Brassica napus                    	     4
 Gallus gallus                     	     2
 Gossypium                         	     1
 Helianthus                        	     4
 Helianthus annuus                 	     2
 Homo sapiens                      	     1
 Maize                             	     2
 Medicago sativa                   	     1
 Medicago truncatula               	    18
 Oryza sativa                      	     8
 Physcomitrella patens             	     1
 Pisum sativum L                   	     4
 Populus deltoides x Populus nigra 	     6
 Populus tremula x Populus alba    	     6
 Rosa chinensis                    	     2
 Rosa gallica                      	     1
 Rosa hybrida                      	     3
 Rosa wichurana                    	     1
 Solanum lycopersicum              	     1
 Thellungiella                     	     1
 Triticum aestivum                 	     2
 Vitis vinifera                    	     3
 Zea mays                          	     8
(27 rows)

# En profiter pour corriger les bugs sur certaines espèces, 
# genre Brassica tout seul = est-ce Brassica napus ? 
#       Maize est-ce Zea mays ?

Idem pour Brachypodium, Gossypium, Helianthus, Thellungiella et Wheat ?

