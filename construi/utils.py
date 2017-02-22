import os.path
import yaml


def load_images_names(working_dir):
    yml = {}
    try:
        with open(os.path.join(working_dir, '.construi.yml')) as f:
            yml = yaml.safe_load(f)
    except:
        pass
    return yml


def save_images_names_to_file(working_dir, yml):
    with open(os.path.join(working_dir, '.construi.yml'), 'w') as f:
        yaml.dump(yml, f)
