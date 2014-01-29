This sample project shows how simple sound generator objects can be combined to produce interesting sounds. In this case, an abstract generator class is extended to create a sine wave generator and a harmonics generator. The harmonics generator combines several sine waves, allowing the programmer to specify what ratio each harmonic wave is to the base frequency, and it's amplitude. 

The values chosen are taken from a research paper "A Study of Harmonic Overtones Produced in Indian Drums". This drone has roughly the characteristics of Mridangam. 

This project is based upon https://github.com/dreamwieber/sine-wave

Run:

	git submodule init
	
	git submodule update
	

Add TheAmazingAudioEngine/TheAmazingAudioEngine.xcproject to your project at the top-level. Xcode will ask you to create a workspace from your project. Build and run from the workspace.
