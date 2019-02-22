## Requètes pour avoir nbr d'extract par espèces pour "Arrays" public

select count(distinct e.extract_id), o.organism_name from experiment exp, extract e, sample_source ss, organism o where exp.analysis_type='Arrays' and exp.experiment_id=e.experiment_id and ss.project_id=e.project_id and e.project_id in (select project_id from project where is_public='yes') and ss.organism_id=o.organism_id group by o.organism_name order by organism_name;


 count |           organism_name           
-------+-----------------------------------
     6 | Alopecurus myosuroides 
  4327 | Arabidopsis thaliana
     9 | Brachypodium
     8 | Brassica
    46 | Brassica napus
    14 | Gallus gallus
     4 | Gossypium
   156 | Helianthus
    30 | Helianthus annuus
    18 | Homo sapiens
    32 | Maize
     8 | Medicago sativa
   311 | Medicago truncatula
   105 | Oryza sativa
     6 | Physcomitrella patens
    86 | Pisum sativum L
   134 | Populus deltoides x Populus nigra
   126 | Populus tremula x Populus alba
    20 | Rosa chinensis
     8 | Rosa gallica
    38 | Rosa hybrida 
    26 | Rosa wichurana 
     8 | Solanum lycopersicum
     4 | Thellungiella
   106 | Triticum aestivum
    54 | Vitis vinifera
    58 | Zea mays
(27 rows)

## Requètes pour avoir nbr d'extract par espèces pour RNA-Seq
##   is_public=NO pour exemple mais quelques projets passeront public quand interface ok

select count(distinct e.extract_id), o.organism_name from experiment exp, extract e, sample_source ss, organism o where exp.analysis_type='RNA-Seq' and exp.experiment_id=e.experiment_id and ss.project_id=e.project_id and e.project_id in (select project_id from project where is_public='no') and ss.organism_id=o.organism_id group by o.organism_name order by organism_name; 

 count |      organism_name       
-------+--------------------------
     9 | Alopecurus myosuroides 
   272 | Arabidopsis thaliana
    18 | Barley
    24 | Brassica napus
    20 | Cephalanthera damasonium
    18 | Citrus sinensis
    20 | Epipactis helleborine
    20 | Epipactis purpurata
    21 | Hevea
    52 | Maize
     6 | Medicago truncatula
     6 | Oryza sativa
    27 | Physcomitrella patens
    48 | Populus nigra
    18 | Rosa chinensis
    18 | Rosa hybrida 
    35 | Vitis vinifera
    18 | Wheat
(18 rows)

 
