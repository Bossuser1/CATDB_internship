

var data1=[{
	    '_key': 1,
	    'project_id': '363',
	    'project_name': 'AFFY_MED_2013_05',
	    'experiment1': {
	        'experiment_id': '536',
	        'experiment_name': 'AFFY_MED_2013_05',
	        'experiment_type': 'gene knock out',
	        'array_type': 'Affymetrix',
	        'organism1': {
	            'organ': 'roots',
	            'organism_name': 'Medicago truncatula',
	            'organism_id': '13'
	        }
	    }
	}, {
	    '_key': 2,
	    'project_id': '279',
	    'project_name': 'RA10-04_Roots',
	    'experiment1': {
	        'experiment_id': '448',
	        'experiment_name': 'WS vs Clca2/35A2/352.7',
	        'experiment_type': 'gene knock out,genotype comparaison,normal vs transgenic comparaison',
	        'array_type': 'CATMA',
	        'organism1': {
	            'organ': 'roots',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 3,
	    'project_id': '282',
	    'project_name': 'AU10-13_CellWall',
	    'experiment1': {
	        'experiment_id': '451',
	        'experiment_name': 'cell wall mutants ',
	        'experiment_type': 'gene knock in (transgenic),normal vs transgenic comparaison',
	        'array_type': 'CATMA',
	        'organism1': {
	            'organ': 'stem',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 4,
	    'project_id': '311',
	    'project_name': 'RS11-10_URT1',
	    'experiment1': {
	        'experiment_id': '482',
	        'experiment_name': 'Leaf transcriptome comparison between wt and URT1 (SALK_087647) ',
	        'experiment_type': 'gene knock out',
	        'array_type': 'NimbleGen',
	        'organism1': {
	            'organ': 'rosette',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 5,
	    'project_id': '447',
	    'project_name': 'NGS2017_10_cpk5_6',
	    'experiment1': {
	        'experiment_id': '631',
	        'experiment_name': 'Treatment of Col0 and cpk',
	        'experiment_type': 'genotype comparaison,treated vs untreated comparison',
	        'array_type': 'Illumina',
	        'organism1': {
	            'organ': 'seedling',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}];

console.clear();


console.log(Object.keys(data1[0]))