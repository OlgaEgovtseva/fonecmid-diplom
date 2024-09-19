///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Запускает процесс формирования отчета в форме отчета.
//  После завершения формирования вызывается ОбработчикЗавершения.
//
// Параметры:
//   ФормаОтчета - ФормаКлиентскогоПриложения - форма отчета.
//   ОбработчикЗавершения - ОписаниеОповещения - обработчик, который будет вызван после формирования отчета.
//     В 1-й параметр процедуры, указанной в ОбработчикЗавершения,
//     передается параметр: ОтчетСформирован (Булево) - признак того, что отчет был успешно сформирован.
//
Процедура СформироватьОтчет(ФормаОтчета, ОбработчикЗавершения = Неопределено) Экспорт
	Если ТипЗнч(ОбработчикЗавершения) = Тип("ОписаниеОповещения") Тогда
		ФормаОтчета.ОбработчикПослеФормированияНаКлиенте = ОбработчикЗавершения;
	КонецЕсли;
	ФормаОтчета.ПодключитьОбработчикОжидания("Сформировать", 0.1, Истина);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Методы работы с СКД из формы отчета.

Функция ТипЗначенияОграниченныйСвязьюПоТипу(Настройки, ПользовательскиеНастройки, ЭлементНастройки, ОписаниеЭлементаНастройки, ТипЗначения = Неопределено) Экспорт 
	Если ОписаниеЭлементаНастройки = Неопределено Тогда 
		Возврат ?(ТипЗначения = Неопределено, Новый ОписаниеТипов("Неопределено"), ТипЗначения);
	КонецЕсли;
	
	Если ТипЗначения = Неопределено Тогда 
		ТипЗначения = ОписаниеЭлементаНастройки.ТипЗначения;
	КонецЕсли;
	
	СвязьПоТипу = ОписаниеЭлементаНастройки.СвязьПоТипу;
	
	СвязанныйЭлементНастройки = ЭлементНастройкиПоПолю(Настройки, ПользовательскиеНастройки, СвязьПоТипу.Поле);
	Если СвязанныйЭлементНастройки = Неопределено Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	ДопустимыеВидыСравнения = Новый Массив;
	ДопустимыеВидыСравнения.Добавить(ВидСравненияКомпоновкиДанных.Равно);
	ДопустимыеВидыСравнения.Добавить(ВидСравненияКомпоновкиДанных.ВИерархии);
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЭлементОтбораКомпоновкиДанных")
		И (Не СвязанныйЭлементНастройки.Использование
		Или ДопустимыеВидыСравнения.Найти(СвязанныйЭлементНастройки.ВидСравнения) = Неопределено) Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	ОписаниеСвязанногоЭлементаНастройки = ОтчетыКлиентСервер.НайтиДоступнуюНастройку(Настройки, СвязанныйЭлементНастройки);
	Если ОписаниеСвязанногоЭлементаНастройки = Неопределено Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных")
		И (ОписаниеСвязанногоЭлементаНастройки.Использование <> ИспользованиеПараметраКомпоновкиДанных.Всегда
		Или Не СвязанныйЭлементНастройки.Использование) Тогда 
		Возврат ТипЗначения;
	КонецЕсли;
	
	Если ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда 
		ЗначениеСвязанногоЭлементаНастройки = СвязанныйЭлементНастройки.Значение;
	ИначеЕсли ТипЗнч(СвязанныйЭлементНастройки) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
		ЗначениеСвязанногоЭлементаНастройки = СвязанныйЭлементНастройки.ПравоеЗначение;
	КонецЕсли;
	
	ТипСубконто = ВариантыОтчетовВызовСервера.ТипСубконто(ЗначениеСвязанногоЭлементаНастройки, СвязьПоТипу.ЭлементСвязи);
	Если ТипЗнч(ТипСубконто) = Тип("ОписаниеТипов") Тогда
		СвязанныеТипы = ТипСубконто.Типы();
	Иначе
		СвязанныеТипы = ОписаниеСвязанногоЭлементаНастройки.ТипЗначения.Типы();
	КонецЕсли;
	
	ВычитаемыеТипы = ТипЗначения.Типы();
	Индекс = ВычитаемыеТипы.ВГраница();
	Пока Индекс >= 0 Цикл 
		Если СвязанныеТипы.Найти(ВычитаемыеТипы[Индекс]) <> Неопределено Тогда 
			ВычитаемыеТипы.Удалить(Индекс);
		КонецЕсли;
		Индекс = Индекс - 1;
	КонецЦикла;
	
	Возврат Новый ОписаниеТипов(ТипЗначения,, ВычитаемыеТипы);
КонецФункции

// Выполняет поиск элемента настройки по полю компоновки данных.
// 
// Параметры:
//   Настройки - НастройкиКомпоновкиДанных
//   ПользовательскиеНастройки - КоллекцияЭлементовПользовательскихНастроекКомпоновкиДанных
//   Поле - ПолеКомпоновкиДанных
// 
// Возвращаемое значение:
//   Неопределено
//
Функция ЭлементНастройкиПоПолю(Настройки, ПользовательскиеНастройки, Поле)
	ЭлементНастройки = ЭлементПараметровДанныхПоПолю(Настройки, ПользовательскиеНастройки, Поле);
	
	Если ЭлементНастройки = Неопределено Тогда 
		НайтиЭлементОтбораПоПолю(Поле, Настройки.Отбор.Элементы, ПользовательскиеНастройки, ЭлементНастройки);
	КонецЕсли;
	
	Возврат ЭлементНастройки;
КонецФункции

Функция ЭлементПараметровДанныхПоПолю(Настройки, ПользовательскиеНастройки, Поле)
	Если ТипЗнч(Настройки) <> Тип("НастройкиКомпоновкиДанных") Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	ЭлементыНастроек = Настройки.ПараметрыДанных.Элементы;
	Для Каждого Элемент Из ЭлементыНастроек Цикл 
		ЭлементПользовательский = ПользовательскиеНастройки.Найти(Элемент.ИдентификаторПользовательскойНастройки);
		ЭлементАнализируемый = ?(ЭлементПользовательский = Неопределено, Элемент, ЭлементПользовательский);
		
		Поля = Новый Массив;
		Поля.Добавить(Новый ПолеКомпоновкиДанных(Строка(Элемент.Параметр)));
		Поля.Добавить(Новый ПолеКомпоновкиДанных("ПараметрыДанных." + Строка(Элемент.Параметр)));
		
		Если ЭлементАнализируемый.Использование
			И (Поля[0] = Поле Или Поля[1] = Поле) Тогда 
			
			Возврат ЭлементАнализируемый;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
КонецФункции

Процедура НайтиЭлементОтбораПоПолю(Поле, ЭлементыОтбора, ПользовательскиеНастройки, ЭлементНастройки)
	Для Каждого Элемент Из ЭлементыОтбора Цикл 
		Если ТипЗнч(Элемент) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда 
			НайтиЭлементОтбораПоПолю(Поле, Элемент.Элементы, ПользовательскиеНастройки, ЭлементНастройки)
		Иначе
			ЭлементПользовательский = ПользовательскиеНастройки.Найти(Элемент.ИдентификаторПользовательскойНастройки);
			ЭлементАнализируемый = ?(ЭлементПользовательский = Неопределено, Элемент, ЭлементПользовательский);
			
			Если ЭлементАнализируемый.Использование И Элемент.ЛевоеЗначение = Поле Тогда 
				ЭлементНастройки = ЭлементАнализируемый;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

// Возвращает полное описание элемента настройки, включая элемент пользовательской настройки, доступное поле отбора
// компоновки данных, индекс и сами настройки компоновки данных, которым подчинен текущий элемент.
// 
// Параметры:
//   КомпоновщикНастроек - КомпоновщикНастроекКомпоновкиДанных
//   Идентификатор - Число
//                 - Строка
// 
// Возвращаемое значение:
//   Структура:
//   * Описание - Неопределено
//              - ДоступныйОбъектНастройкиКомпоновкиДанных
//              - ДоступноеПолеКомпоновкиДанных
//   * Элемент - КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных
//             - ДиаграммаКомпоновкиДанных
//             - НастройкиВложенногоОбъектаКомпоновкиДанных
//             - ВыбранныеПоляКомпоновкиДанных
//             - НастройкиКомпоновкиДанных
//             - ГруппировкаКомпоновкиДанных
//             - ГруппировкаТаблицыКомпоновкиДанных
//             - УсловноеОформлениеКомпоновкиДанных
//             - Неопределено
//             - ОтборКомпоновкиДанных
//             - КоллекцияЭлементовСтруктурыНастроекКомпоновкиДанных
//             - ПорядокКомпоновкиДанных
//             - ТаблицаКомпоновкиДанных
//             - ГруппировкаДиаграммыКомпоновкиДанных
//             - КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных
//   * ЭлементПользовательскойНастройки - ЭлементОтбораКомпоновкиДанных
//                                      - ЗначениеПараметраКомпоновкиДанных
//   * Индекс - Число
//   * Настройки - НастройкиКомпоновкиДанных
// 
Функция СведенияОЭлементеНастройки(КомпоновщикНастроек, Идентификатор) Экспорт 
	Настройки = КомпоновщикНастроек.Настройки;
	ПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки;
	
	Если ТипЗнч(Идентификатор) = Тип("Число") Тогда 
		Индекс = Идентификатор;
	Иначе
		Индекс = ОтчетыКлиентСервер.ИндексЭлементаНастройкиПоПути(Идентификатор);
	КонецЕсли;
	
	ЭлементПользовательскойНастройки = ПользовательскиеНастройки.Элементы[Индекс];
	
	ИерархияНастроек = Новый Массив;
	Элемент = ОтчетыКлиентСервер.ПолучитьОбъектПоПользовательскомуИдентификатору(
		Настройки,
		ЭлементПользовательскойНастройки.ИдентификаторПользовательскойНастройки,
		ИерархияНастроек,
		ПользовательскиеНастройки);
	
	Настройки = ?(ИерархияНастроек.Количество() > 0, ИерархияНастроек[ИерархияНастроек.ВГраница()], Настройки);
	Описание = ОтчетыКлиентСервер.НайтиДоступнуюНастройку(Настройки, Элемент);
	
	Сведения = Новый Структура;
	Сведения.Вставить("Настройки", Настройки);
	Сведения.Вставить("Индекс", Индекс);
	Сведения.Вставить("ЭлементПользовательскойНастройки", ЭлементПользовательскойНастройки);
	Сведения.Вставить("Элемент", Элемент);
	Сведения.Вставить("Описание", Описание);
	
	Возврат Сведения;
КонецФункции

// Определяет значения типа ИспользованиеГруппИЭлементов в зависимости от вида сравнения (приоритетно) или исходного значения.
//
// Параметры:
//  Условие - ВидСравненияКомпоновкиДанных
//          - Неопределено - текущее значение вида сравнения.
//  ИсходноеЗначение - ИспользованиеГруппИЭлементов
//                   - ГруппыИЭлементы - текущее значение свойства
//                     ВыборГруппИЭлементов.
//
// Возвращаемое значение:
//   ИспользованиеГруппИЭлементов - значение перечисления ИспользованиеГруппИЭлементов.
//
Функция ЗначениеТипаИспользованиеГруппИЭлементов(ИсходноеЗначение, Условие = Неопределено) Экспорт
	Если Условие <> Неопределено Тогда 
		Если Условие = ВидСравненияКомпоновкиДанных.ВСпискеПоИерархии
			Или Условие = ВидСравненияКомпоновкиДанных.НеВСпискеПоИерархии Тогда 
			Если ИсходноеЗначение = ГруппыИЭлементы.Группы
				Или ИсходноеЗначение = ИспользованиеГруппИЭлементов.Группы Тогда 
				Возврат ИспользованиеГруппИЭлементов.Группы;
			Иначе
				Возврат ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
			КонецЕсли;
		ИначеЕсли Условие = ВидСравненияКомпоновкиДанных.ВИерархии
			Или Условие = ВидСравненияКомпоновкиДанных.НеВИерархии Тогда 
			Возврат ИспользованиеГруппИЭлементов.Группы;
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(ИсходноеЗначение) = Тип("ИспользованиеГруппИЭлементов") Тогда 
		Возврат ИсходноеЗначение;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.Элементы Тогда
		Возврат ИспользованиеГруппИЭлементов.Элементы;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.ГруппыИЭлементы Тогда
		Возврат ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
	ИначеЕсли ИсходноеЗначение = ГруппыИЭлементы.Группы Тогда
		Возврат ИспользованиеГруппИЭлементов.Группы;
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции

#Область ПериодОтчета

// Вызывает диалог редактирования стандартного периода.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма отчета или форма настроек отчета.
//  ИмяКоманды - Строка - имя команды выбора периода, содержащее путь к значению периода.
//  ВариантПериода - Неопределено
//                 - ПеречислениеСсылка.ВариантыПериода
//
Процедура ВыбратьПериод(Форма, ИмяКоманды, ВариантПериода = Неопределено) Экспорт
	Путь = СтрЗаменить(ИмяКоманды, "ВыбратьПериод", "Период");
	Период = Форма[Путь];
	
	Контекст = Новый Структура();
	Контекст.Вставить("Форма", Форма);
	Контекст.Вставить("ИмяКоманды", ИмяКоманды);
	Контекст.Вставить("Путь", Путь);
	Контекст.Вставить("Период", Период);
	
	Обработчик = Новый ОписаниеОповещения("ВыбратьПериодЗавершение", ЭтотОбъект, Контекст);
	
	СтандартнаяОбработка = Истина;
	ОтчетыКлиентПереопределяемый.ПриНажатииКнопкиВыбораПериода(Форма, Период, СтандартнаяОбработка, Обработчик);
	
	Если Не СтандартнаяОбработка Тогда
		Возврат;
	КонецЕсли;
	
	Если ВариантПериода = Неопределено Тогда 
		ВариантПериода = Форма.НастройкиОтчета.ВариантПериода;
	КонецЕсли;
	
	Если ВариантПериода = ПредопределенноеЗначение("Перечисление.ВариантыПериода.Финансовый") Тогда 
	
		Контекст.Удалить("Форма");
		
		ОткрытьФорму("ХранилищеНастроек.ХранилищеВариантовОтчетов.Форма.ВыборФинансовогоПериода",
			Контекст,
			Форма,,,,
			Обработчик);
		
	Иначе
	
		Диалог = Новый ДиалогРедактированияСтандартногоПериода;
		Диалог.Период = Период;
		Диалог.Показать(Обработчик);
		
	КонецЕсли;
КонецПроцедуры

// Выполняет сдвиг периода назад или вперед.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма отчета или форма настроек отчета.
//  ИмяКоманды - Строка - имя команды выбора периода, содержащее путь к значению периода.
//
Процедура СдвинутьПериод(Форма, ИмяКоманды) Экспорт
	Если СтрНайти(НРег(ИмяКоманды), "назад") > 0 Тогда 
		
		НаправлениеСдвига = -1;
		Путь = СтрЗаменить(ИмяКоманды, "СдвинутьПериодНазад", "Период");
	Иначе 
		НаправлениеСдвига = 1;
		Путь = СтрЗаменить(ИмяКоманды, "СдвинутьПериодВперед", "Период");
	КонецЕсли;
	
	Период = Форма[Путь]; // СтандартныйПериод
	
	Если Не ЗначениеЗаполнено(Период.ДатаНачала)
		Или Не ЗначениеЗаполнено(Период.ДатаОкончания) Тогда 
		
		Возврат;
	КонецЕсли;
	
	Если Период.ДатаНачала = НачалоДня(Период.ДатаОкончания) Тогда
		
		Период.ДатаНачала = Период.ДатаНачала + 86400 * НаправлениеСдвига;
		Период.ДатаОкончания = КонецДня(Период.ДатаНачала);
		
	ИначеЕсли Период.ДатаНачала = НачалоМесяца(Период.ДатаОкончания) Тогда
		
		Период.ДатаНачала = ДобавитьМесяц(Период.ДатаНачала, НаправлениеСдвига);
		Период.ДатаОкончания = КонецМесяца(Период.ДатаНачала);
		
	ИначеЕсли Период.ДатаНачала = НачалоКвартала(Период.ДатаОкончания) Тогда
		
		Период.ДатаНачала = ДобавитьМесяц(Период.ДатаНачала, 3 * НаправлениеСдвига);
		Период.ДатаОкончания = КонецКвартала(Период.ДатаНачала);
		
	ИначеЕсли Период.ДатаНачала = НачалоГода(Период.ДатаОкончания)
		И КонецГода(Период.ДатаНачала) = Период.ДатаОкончания Тогда
		
		Период.ДатаНачала = ДобавитьМесяц(Период.ДатаНачала, 12 * НаправлениеСдвига);
		Период.ДатаОкончания = КонецГода(Период.ДатаНачала);
		
	ИначеЕсли Период.ДатаНачала = НачалоГода(Период.ДатаОкончания)
		И (Месяц(Период.ДатаОкончания) = 6 Или Месяц(Период.ДатаОкончания) = 9) Тогда
		
		Период.ДатаНачала = ДобавитьМесяц(Период.ДатаНачала, 12 * НаправлениеСдвига);
		Период.ДатаОкончания = ДобавитьМесяц(Период.ДатаОкончания, 12 * НаправлениеСдвига);
		
	КонецЕсли;
	
	Форма[Путь] = Период;
	УстановитьПериод(Форма, Путь);
	
	ОтчетыКлиентСервер.ОповеститьОИзмененииНастроек(Форма);
КонецПроцедуры

// Обработчик редактирования стандартного периода.
//
// Параметры:
//  РезультатВыбора - Структура:
//                  - СтандартныйПериод - значение, возвращенное диалогом.
//  Контекст - Структура - содержит форму отчета (настроек) и путь к значению периода.
//
Процедура ВыбратьПериодЗавершение(РезультатВыбора, Контекст) Экспорт 
	Если РезультатВыбора = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(РезультатВыбора) = Тип("Структура")
		И РезультатВыбора.Свойство("Событие") Тогда 
		
		ВыбратьПериод(РезультатВыбора.ВладелецФормы, РезультатВыбора.ИмяКоманды, РезультатВыбора.ВариантПериода);
		Возврат;
		
	ИначеЕсли ТипЗнч(РезультатВыбора) = Тип("Структура") Тогда 
		
		Форма = РезультатВыбора.ВладелецФормы;
		Период = РезультатВыбора.Период;
		
	Иначе
		
		Форма = Контекст.Форма;
		Период = РезультатВыбора;
		
	КонецЕсли;
	
	Форма[Контекст.Путь] = Период;
	УстановитьПериод(Форма, Контекст.Путь);
	
	ОтчетыКлиентСервер.ОповеститьОИзмененииНастроек(Форма);
КонецПроцедуры

// Инициализирует значение элемента настройки периода.
// 
// Параметры:
//   Форма - ФормаКлиентскогоПриложения
//         - РасширениеФормыОтчета:
//     * Отчет - ОтчетОбъект
//   Путь - Строка
//
Процедура УстановитьПериод(Форма, Знач Путь) Экспорт 
	КомпоновщикНастроек = Форма.Отчет.КомпоновщикНастроек;
	
	Свойства = СтрРазделить("ДатаНачала, ДатаОкончания", ", ", Ложь);
	Для Каждого Свойство Из Свойства Цикл 
		Путь = СтрЗаменить(Путь, Свойство, "");
	КонецЦикла;
	
	Индекс = Форма.ПутьКДаннымЭлементов.ПоИмени[Путь];
	Если Индекс = Неопределено Тогда 
		Путь = Путь + "Период";
		Индекс = Форма.ПутьКДаннымЭлементов.ПоИмени[Путь];
	КонецЕсли;
	
	Период = Форма[Путь]; // СтандартныйПериод
	
	ЭлементПользовательскойНастройки = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы[Индекс];
	ЭлементПользовательскойНастройки.Использование = Истина;
	
	Если ТипЗнч(ЭлементПользовательскойНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда 
		ЭлементПользовательскойНастройки.Значение = Период;
	Иначе // Элемент отбора.
		ЭлементПользовательскойНастройки.ПравоеЗначение = Период;
	КонецЕсли;
	
	ИмяКнопкиВыбораПериода = СтрЗаменить(Путь, "Период", "ВыбратьПериод");
	КнопкаВыбораПериода = Форма.Элементы.Найти(ИмяКнопкиВыбораПериода);
	КнопкаВыбораПериода.Заголовок = СтроковыеФункцииКлиент.ПредставлениеПериодаВТексте(
		Период.ДатаНачала, Период.ДатаОкончания);
	
	ОтчетыКлиентСервер.ОповеститьОИзмененииНастроек(Форма);
КонецПроцедуры

#КонецОбласти

#Область Прочее

Функция ПриДобавленииВКоллекциюНужноУказыватьТипЭлемента(ТипКоллекции) Экспорт
	Возврат ТипКоллекции <> Тип("КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных")
		И ТипКоллекции <> Тип("КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных")
		И ТипКоллекции <> Тип("КоллекцияЭлементовУсловногоОформленияКомпоновкиДанных");
КонецФункции

Процедура КэшироватьЗначениеОтбора(КомпоновщикНастроек, ЭлементОтбора, ЗначениеОтбора) Экспорт 
	ДополнительныеСвойства = КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства;
	
	КэшЗначенийОтборов = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		ДополнительныеСвойства, "КэшЗначенийОтборов", Новый Соответствие);
	
	ЭлементОтбораОсновныхНастроек = Неопределено;
	
	Если ЗначениеЗаполнено(ЭлементОтбора.ИдентификаторПользовательскойНастройки) Тогда 
		
		КэшЗначенийОтборов.Вставить(ЭлементОтбора.ИдентификаторПользовательскойНастройки, ЗначениеОтбора);
		
		НайденныеЭлементыНастроек = КомпоновщикНастроек.ПользовательскиеНастройки.ПолучитьОсновныеНастройкиПоИдентификаторуПользовательскойНастройки(
			ЭлементОтбора.ИдентификаторПользовательскойНастройки);
		
		Если НайденныеЭлементыНастроек.Количество() > 0 Тогда 
			ЭлементОтбораОсновныхНастроек = НайденныеЭлементыНастроек[0];
		КонецЕсли;
		
	Иначе
		ЭлементОтбораОсновныхНастроек = ЭлементОтбора;
	КонецЕсли;
	
	Если ТипЗнч(ЭлементОтбораОсновныхНастроек) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
		КэшЗначенийОтборов.Вставить(ЭлементОтбораОсновныхНастроек.ЛевоеЗначение, ЗначениеОтбора);
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("КэшЗначенийОтборов", КэшЗначенийОтборов);
КонецПроцедуры

Функция КэшЗначенияОтбора(КомпоновщикНастроек, ЭлементОтбора) Экспорт 
	ЗначениеОтбора = Неопределено;
	
	ДополнительныеСвойства = КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства;
	
	КэшЗначенийОтборов = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		ДополнительныеСвойства, "КэшЗначенийОтборов", Новый Соответствие);
	
	Если ЗначениеЗаполнено(ЭлементОтбора.ИдентификаторПользовательскойНастройки) Тогда 
		ЗначениеОтбора = КэшЗначенийОтборов[ЭлементОтбора.ИдентификаторПользовательскойНастройки];
	КонецЕсли;
	
	Если ЗначениеОтбора <> Неопределено Тогда 
		Возврат ЗначениеОтбора;
	КонецЕсли;
	
	ЭлементОтбораОсновныхНастроек = Неопределено;
	
	Если ЗначениеЗаполнено(ЭлементОтбора.ИдентификаторПользовательскойНастройки) Тогда 
		
		НайденныеЭлементыНастроек = КомпоновщикНастроек.ПользовательскиеНастройки.ПолучитьОсновныеНастройкиПоИдентификаторуПользовательскойНастройки(
			ЭлементОтбора.ИдентификаторПользовательскойНастройки);
		
		Если НайденныеЭлементыНастроек.Количество() > 0 Тогда 
			ЭлементОтбораОсновныхНастроек = НайденныеЭлементыНастроек[0];
		КонецЕсли;
		
	Иначе
		ЭлементОтбораОсновныхНастроек = ЭлементОтбора;
	КонецЕсли;
	
	Если ТипЗнч(ЭлементОтбораОсновныхНастроек) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
		ЗначениеОтбора = КэшЗначенийОтборов[ЭлементОтбораОсновныхНастроек.ЛевоеЗначение];
	КонецЕсли;
	
	Возврат ЗначениеОтбора;
КонецФункции

// Определяет полный путь к элементу компоновки данных.
//
// Параметры:
//   Настройки - НастройкиКомпоновкиДанных - корневой узел настроек, от которого строится полный путь.
//   ЭлементНастроек - НастройкиКомпоновкиДанных
//                   - НастройкиВложенногоОбъектаКомпоновкиДанных
//                   - ТаблицаКомпоновкиДанных
//                   - КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных
//                   - ДиаграммаКомпоновкиДанных
//                   - КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных
//                   - ЭлементОтбораКомпоновкиДанных
//                   - ГруппаЭлементовОтбораКомпоновкиДанных
//                   - ЗначениеПараметраКомпоновкиДанных
//                   - ГруппаЭлементовОтбораКомпоновкиДанных
//
// Возвращаемое значение:
//   Строка - полный путь к элементу. Может использоваться в функции НайтиЭлементПоПолномуПути().
//   Неопределено - если не удалось построить полный путь.
//
Функция ПолныйПутьКЭлементуНастроек(Знач Настройки, Знач ЭлементНастроек) Экспорт
	Результат = Новый Массив;
	РодительЭлементаНастроек = ЭлементНастроек;
	
	Пока РодительЭлементаНастроек <> Неопределено
		И РодительЭлементаНастроек <> Настройки Цикл
		
		ЭлементНастроек = РодительЭлементаНастроек;
		РодительЭлементаНастроек = РодительЭлементаНастроек.Родитель;
		ТипРодителя = ТипЗнч(РодительЭлементаНастроек);
		
		Если ТипРодителя = Тип("ТаблицаКомпоновкиДанных") Тогда
			СтрокиТаблицы = РодительЭлементаНастроек.Строки; // КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных
			Индекс = СтрокиТаблицы.Индекс(ЭлементНастроек);
			Если Индекс = -1 Тогда
				КолонкиТаблицы = РодительЭлементаНастроек.Колонки; // КоллекцияЭлементовСтруктурыТаблицыКомпоновкиДанных
				Индекс = КолонкиТаблицы.Индекс(ЭлементНастроек);
				ИмяКоллекции = "Колонки";
			Иначе
				ИмяКоллекции = "Строки";
			КонецЕсли;
		ИначеЕсли ТипРодителя = Тип("ДиаграммаКомпоновкиДанных") Тогда
			СерииДиаграммы = РодительЭлементаНастроек.Серии; // КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных
			Индекс = СерииДиаграммы.Индекс(ЭлементНастроек);
			Если Индекс = -1 Тогда
				ТочкиДиаграммы = РодительЭлементаНастроек.Точки; // КоллекцияЭлементовСтруктурыДиаграммыКомпоновкиДанных
				Индекс = ТочкиДиаграммы.Индекс(ЭлементНастроек);
				ИмяКоллекции = "Точки";
			Иначе
				ИмяКоллекции = "Серии";
			КонецЕсли;
		ИначеЕсли ТипРодителя = Тип("НастройкиВложенногоОбъектаКомпоновкиДанных") Тогда
			ИмяКоллекции = "Настройки";
			Индекс = Неопределено;
		Иначе
			ИмяКоллекции = "Структура";
			Индекс = РодительЭлементаНастроек.Структура.Индекс(ЭлементНастроек);
		КонецЕсли;
		
		Если Индекс = -1 Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		Если Индекс <> Неопределено Тогда
			Результат.Вставить(0, Индекс);
		КонецЕсли;
		
		Результат.Вставить(0, ИмяКоллекции);
	КонецЦикла;
	
	Возврат СтрСоединить(Результат, "/");
КонецФункции

Функция ВыборПереопределен(ФормаОтчета, Знач Обработчик, ЭлементКомпоновки,
			ДоступныеТипы, ОтмеченныеЗначения, ПараметрыВыбора) Экспорт

	Если ТипЗнч(ЭлементКомпоновки) = Тип("ДоступныйПараметрКомпоновкиДанных") Тогда
		ИмяПоля = Строка(ЭлементКомпоновки.Параметр);
	ИначеЕсли ТипЗнч(ЭлементКомпоновки) = Тип("ДоступноеПолеОтбораКомпоновкиДанных") Тогда
		ИмяПоля = Строка(ЭлементКомпоновки.Поле);
	Иначе
		ИмяПоля = "";
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ИмяПоля) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	УсловияВыбора = Новый Структура;
	УсловияВыбора.Вставить("ИмяПоля",           ИмяПоля);
	УсловияВыбора.Вставить("ЭлементКомпоновки", ЭлементКомпоновки);
	УсловияВыбора.Вставить("ДоступныеТипы",     ДоступныеТипы);
	УсловияВыбора.Вставить("Отмеченные",        ОтмеченныеЗначения);
	УсловияВыбора.Вставить("ПараметрыВыбора",   Новый Массив(ПараметрыВыбора));
	
	ОткрытьСтандартнуюФорму = Истина;
	ИнтеграцияПодсистемБСПКлиент.ПриНачалеВыбораЗначений(ФормаОтчета, УсловияВыбора, Обработчик, ОткрытьСтандартнуюФорму);
	ОтчетыКлиентПереопределяемый.ПриНачалеВыбораЗначений(ФормаОтчета, УсловияВыбора, Обработчик, ОткрытьСтандартнуюФорму);
	
	Возврат Не ОткрытьСтандартнуюФорму;
	
КонецФункции

Функция ЭтоВыборОбъектовМетаданных(ДоступныеТипы, Знач ОтмеченныеЗначения, Обработчик) Экспорт 
	СоставТипов = ДоступныеТипы.Типы();
	
	Индекс = СоставТипов.ВГраница();
	Пока Индекс >= 0 Цикл 
		Если СоставТипов.Найти(Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных")) <> Неопределено
			Или СоставТипов.Найти(Тип("СправочникСсылка.ИдентификаторыОбъектовРасширений")) <> Неопределено Тогда 
			
			СоставТипов.Удалить(Индекс);
		КонецЕсли;
		
		Индекс = Индекс - 1;
	КонецЦикла;
	
	ЭтоВыборОбъектовМетаданных = ДоступныеТипы.Типы().Количество() > 0 И СоставТипов.Количество() = 0;
	
	Если ЭтоВыборОбъектовМетаданных Тогда 
		ПроверитьОтмеченныеЗначения(ОтмеченныеЗначения, ДоступныеТипы);
		
		ПараметрыПодбора = Новый Структура;
		ПараметрыПодбора.Вставить("ВыбранныеОбъектыМетаданных", ОтмеченныеЗначения);
		ПараметрыПодбора.Вставить("ВыбиратьСсылки", Истина);
		ПараметрыПодбора.Вставить("Заголовок", НСтр("ru = 'Подбор таблиц'"));
		
		ОткрытьФорму("ОбщаяФорма.ВыборОбъектовМетаданных", ПараметрыПодбора,,,,, Обработчик);
	КонецЕсли;
	
	Возврат ЭтоВыборОбъектовМетаданных;
КонецФункции

Функция ЭтоВыборПользователей(Форма, ЭлементФормы, ДоступныеТипы, Знач ОтмеченныеЗначения, ПараметрыВыбора, Обработчик) Экспорт 
	
	КоличествоТипов = ДоступныеТипы.Типы().Количество();
	
	Если КоличествоТипов = 1 Тогда
		ЭтоВыборПользователей =
			    ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи"))
			Или ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ВнешниеПользователи"));
		
	ИначеЕсли КоличествоТипов = 2 Тогда
		ЭтоВыборПользователей =
			    ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ВнешниеПользователи"))
			Или ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыПользователей"))
			Или ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ВнешниеПользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыВнешнихПользователей"));
		
	ИначеЕсли КоличествоТипов = 4 Тогда
		ЭтоВыборПользователей =
			    ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыПользователей"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ВнешниеПользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыВнешнихПользователей"));
	Иначе
		ЭтоВыборПользователей = Ложь;
	КонецЕсли;
	
	Если ЭтоВыборПользователей Тогда 
		ПроверитьОтмеченныеЗначения(ОтмеченныеЗначения, ДоступныеТипы);
		ВыбратьТип =
			    КоличествоТипов = 4
			Или КоличествоТипов = 2
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи"))
			  И ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ВнешниеПользователи"));
		
		Контекст = Новый Структура;
		Контекст.Вставить("ДоступныеТипы",      ДоступныеТипы);
		Контекст.Вставить("ОтмеченныеЗначения", ОтмеченныеЗначения);
		Контекст.Вставить("ПараметрыВыбора",    ПараметрыВыбора);
		Контекст.Вставить("Обработчик",         Обработчик);
		
		СписокТиповПользователей = Новый СписокЗначений;
		
		Если Не ВыбратьТип Тогда
			Если ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.Пользователи")) Тогда
				СписокТиповПользователей.Добавить(Тип("СправочникСсылка.Пользователи"));
			Иначе
				СписокТиповПользователей.Добавить(Тип("СправочникСсылка.ВнешниеПользователи"));
			КонецЕсли;
			ВыбратьПользователейПослеВыбораТипа(СписокТиповПользователей[0], Контекст);
		Иначе
			СписокТиповПользователей.Добавить(Тип("СправочникСсылка.Пользователи"));
			СписокТиповПользователей.Добавить(Тип("СправочникСсылка.ВнешниеПользователи"));
			Форма.ПоказатьВыборИзМеню(
				Новый ОписаниеОповещения("ВыбратьПользователейПослеВыбораТипа", ЭтотОбъект, Контекст),
				СписокТиповПользователей,
				ЭлементФормы);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ЭтоВыборПользователей;
	
КонецФункции

Процедура ПроверитьОтмеченныеЗначения(ОтмеченныеЗначения, ДоступныеТипы)
	
	Индекс = ОтмеченныеЗначения.Количество() - 1;
	
	Пока Индекс >= 0 Цикл 
		Элемент = ОтмеченныеЗначения[Индекс];
		Индекс = Индекс - 1;
		
		Если Не ДоступныеТипы.СодержитТип(ТипЗнч(Элемент.Значение))
		 Или Не ЗначениеЗаполнено(Элемент.Значение) Тогда 
			ОтмеченныеЗначения.Удалить(Элемент);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ВыбратьПользователейПослеВыбораТипа(ВыбранныйЭлемент, Контекст) Экспорт
	
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПодбора = Новый Структура;
	
	Если ВыбранныйЭлемент.Значение = Тип("СправочникСсылка.Пользователи") Тогда
		ПолноеИмяФормыВыбора = "Справочник.Пользователи.ФормаВыбора";
		Если Контекст.ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыПользователей")) Тогда 
			ПараметрыПодбора.Вставить("ВыборГруппПользователей", Истина);
			ЗаголовокФормыПодбора = НСтр("ru = 'Подбор групп и пользователей'");
		Иначе
			ЗаголовокФормыПодбора = НСтр("ru = 'Подбор пользователей'");
		КонецЕсли;
	Иначе
		ПолноеИмяФормыВыбора = "Справочник.ВнешниеПользователи.ФормаВыбора";
		Если Контекст.ДоступныеТипы.СодержитТип(Тип("СправочникСсылка.ГруппыПользователей")) Тогда 
			ПараметрыПодбора.Вставить("ВыборГруппВнешнихПользователей", Истина);
			ЗаголовокФормыПодбора = НСтр("ru = 'Подбор групп и внешних пользователей'");
		Иначе
			ЗаголовокФормыПодбора = НСтр("ru = 'Подбор внешних пользователей'");
		КонецЕсли;
	КонецЕсли;
	
	ВыбранныеПользователи = Контекст.ОтмеченныеЗначения.ВыгрузитьЗначения();
	
	ПараметрыПодбора.Вставить("РежимВыбора", Истина);
	ПараметрыПодбора.Вставить("ЗакрыватьПриВыборе", Ложь);
	ПараметрыПодбора.Вставить("МножественныйВыбор", Истина);
	ПараметрыПодбора.Вставить("РасширенныйПодбор", Истина);
	ПараметрыПодбора.Вставить("ПараметрыВыбора", Контекст.ПараметрыВыбора);
	ПараметрыПодбора.Вставить("ЗаголовокФормыПодбора", ЗаголовокФормыПодбора);
	ПараметрыПодбора.Вставить("ВыбранныеПользователи", ВыбранныеПользователи);
	
	ОткрытьФорму(ПолноеИмяФормыВыбора, ПараметрыПодбора, ЭтотОбъект,,,, Контекст.Обработчик);
	
КонецПроцедуры

Процедура ОбновитьПредставленияСписка(СписокПриемник, СписокИсточник) Экспорт 
	
	Если ТипЗнч(СписокИсточник) <> Тип("СписокЗначений") Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Элемент Из СписокИсточник Цикл 
		
		Если Не ЗначениеЗаполнено(Элемент.Представление) Тогда 
			Продолжить;
		КонецЕсли;
		
		НайденныйЭлемент = СписокПриемник.НайтиПоЗначению(Элемент.Значение);
		
		Если НайденныйЭлемент <> Неопределено Тогда 
			НайденныйЭлемент.Представление = Элемент.Представление;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти