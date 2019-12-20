# Installation ugradio and Python Environments

To install on your default coding environment, run ```python setup.py install``` in the terminal from within the `ugradio_code` folder.

However, before you do this, it is suggested to install Python packages within an environment. One method for doing is using [Anaconda](https://www.anaconda.com/distribution/). Download the Python 3 version so that it gives Python 3 as the default version.

A Python (virtual) environment is way of keeping dependencies and softwares versions separate from each other, so that you can organize which versions can talk to each other.

For example, with conda, you can keep both a Python 2 and Python 3 environment. This is important when a library you want to use isn't supported by one of the Python versions -- for example, `astropy` only support Python 3.5 and above. The default Python installation on Mac OS X is Python 2.6, but simply installing Python 3 on the default environment will not overwrite the existing Python installation. 

### Creating an environment

To set up a Python environment, run 

```conda create --name ENV_NAME python```, 

where `ENV_NAME` is whatever name you'd like to call the environment. 
If you want to specify a Python version, you can run 

```conda create --name ENV_NAME python=VERSION```,

where `VERSION` is the Python version number.
So, running 

```conda create --name ugradio2 python=2.7``` 

would create a Python environment called 'ugradio2' running Python 2.7.

### Activing and deactiving environments

To activate this environment, use 

```conda activate ENV_NAME```. 

This changes the PATHs on your machine to point commands like `python` to the appropriate Python installation and libraries. To exit your environment, use 

```conda deactivate```.

### Proceeding

Once you've created your environment, you can install packages the usual way (`pip install PACKAGE`), and those installations will be localized to your current environment.

Similarly, if you now run `python setup.py install` within the `ugradio_code` directory, it will install everything within your environment.

### What is going on?

Your computer finds the versions of all executables and libraries by searching the so-called environmental variables `PATH` and `PYTHONPATH`.

To view this, run `echo $PATH` in your terminal. You should see a set of directory paths. When you run a command, like `python`, your computer searches for an executable named `python` in all the paths starting from the beginning.

Your machine likely comes installed with some version of Python. When you install anaconda / activate an environment, it appends the path to your conda environment at the beginning of `PATH` (on Mac OS X, this might look like `/Users/USERNAME/anaconda3/envs/ENV_NAME/bin`). Since it sees a `python` executable in this path, it uses this version of Python instead of the default installation. By extension, if you were to place this conda path at the *end*, your computer would find `python` in the default path first and use that instead.

### Note about iPython

Note: Anaconda comes installed with `ipython`. You can use the default anaconda environment (labeled `anaconda3`) for your work, but if you decide to create your own environment as shown above, installing `pip install ipython` won't automatically point the command to the correct distribution. To fix this, either `pip uninstall ipython` within the `anaconda3` environment or use `python -m IPython` within your custom `ENV_NAME` environment.


