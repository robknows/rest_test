from setuptools import setup, find_packages

setup(
    name='rest_test',
    version='6.0',
    packages=find_packages(exclude=['test*']),
    license='JSON',
    description='Create tidy integration tests for a RESTful API.',
    long_description=open('README.md').read(),
    install_requires=['termcolor'],
    url='https://github.com/robknows/rest_test',
    author='Rob Moore',
    author_email='robmoore121@gmail.com'
)
