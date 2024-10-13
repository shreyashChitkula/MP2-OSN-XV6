#ifndef RANDOM_H
#define RANDOM_H

#ifdef SCHEDULER_LBS
int rand(void);
void srand(unsigned int seed);
#endif

#endif // RANDOM_H