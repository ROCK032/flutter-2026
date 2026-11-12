# Practice 10

## Уровень 1

### Прогноз

Прогноз заранее не записывался.

### Фактический вывод

```text
A
C
fetchStudents #1
First frame
B
6 students
```

### Третий запрос

```text
Unhandled Exception: Instance of 'NoConnectionException'
```

### Сравнение задержек

С `await Future.delayed(...)` первый кадр был обработан до получения списка.
Со `sleep(...)` до вызова `runApp()` прошло 2013 мс.


## Уровень 2
DartError: setState() called after dispose(): _StudentsScreenState#fefe7(lifecycle state: defunct, not mounted)

## Уровень 4

- StreamBuilder. После выхода отсчёт остановился на `tick 6`, ошибок не было.
- listen() с cancel(). После выхода отсчёт остановился на `tick 6`, ошибок не было.
- listen() без cancel(). После выхода появились ошибки `setState() called after dispose()`, а отсчёт продолжился до `tick 0`.