1. As far as I undersand, Swift has no NSUInteger class, found what it looked like in Objective-C from Apple developers doc and declared type alias
2. Decided to throw custom error if numbers passed to init() are invalid - caused some pain finding out how to create custom exceptions with text
and wrapping all constructors with try/catch
3. When extracting hours, minutes and seconds from NSDate, they are not of Type but of Type?. Took some time to learn the meaning of ?
and how to work with them
4. Written a lot of code without executing, thought that %s in format will accept string but it doesn't. As a result, parts of code which print
are not very beatiful with combination of formatting and string concatenation.

