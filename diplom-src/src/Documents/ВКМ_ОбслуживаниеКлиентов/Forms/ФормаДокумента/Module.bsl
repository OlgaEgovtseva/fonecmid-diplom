
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)

	ДокументИзменен = Ложь;
	ТекстСообщения = "";
	
	Если Не ТекущийОбъект.Проведен Тогда 
		ДокументИзменен = Истина;
		ТекстСообщения =  СтрШаблон("Создан новый документ: %1", ТекущийОбъект);
	Иначе
		ДанныеДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ТекущийОбъект, "ДатаПроведенияРабот, ВремяНачалаРабот_план, ВремяОкончанияРабот_план, Специалист");
		Если ДанныеДокумента.ДатаПроведенияРабот <> ТекущийОбъект.ДатаПроведенияРабот Тогда
			ДокументИзменен = Истина;
			ТекстСообщения = ТекстСообщения + ?(ТекстСообщения <> "", Символы.ПС, "") + СтрШаблон("В документе: %1 изменилась дата проведения работ с %2 на %3", ТекущийОбъект.Ссылка, Формат(ДанныеДокумента.ДатаПроведенияРабот, "ДФ=dd.MM.yyyy;"), Формат(ТекущийОбъект.ДатаПроведенияРабот, "ДФ=dd.MM.yyyy;"));
		КонецЕсли;
		Если ДанныеДокумента.ВремяНачалаРабот_план <> ТекущийОбъект.ВремяНачалаРабот_план Тогда
			ДокументИзменен = Истина;
			ТекстСообщения = ТекстСообщения + ?(ТекстСообщения <> "", Символы.ПС, "") + СтрШаблон("В документе: %1 изменилось время начала работ (план) с %2 на %3", ТекущийОбъект.Ссылка, Формат(ДанныеДокумента.ВремяНачалаРабот_план, "ДЛФ=T;"), Формат(ТекущийОбъект.ВремяНачалаРабот_план, "ДЛФ=T;"));
		КонецЕсли;
		Если ДанныеДокумента.ВремяОкончанияРабот_план <> ТекущийОбъект.ВремяОкончанияРабот_план Тогда
			ДокументИзменен = Истина;
			ТекстСообщения = ТекстСообщения + ?(ТекстСообщения <> "", Символы.ПС, "") + СтрШаблон("В документе: %1 изменилось время окончания работ (план) с %2 на %3", ТекущийОбъект.Ссылка, Формат(ДанныеДокумента.ВремяОкончанияРабот_план, "ДЛФ=T;"), Формат(ТекущийОбъект.ВремяОкончанияРабот_план, "ДЛФ=T;"));
		КонецЕсли;
		Если ДанныеДокумента.Специалист <> ТекущийОбъект.Специалист Тогда
			ДокументИзменен = Истина;
			ТекстСообщения = ТекстСообщения + ?(ТекстСообщения <> "", Символы.ПС, "") + СтрШаблон("В документе: %1 изменился специалист с %2 на %3", ТекущийОбъект.Ссылка, ДанныеДокумента.Специалист, ТекущийОбъект.Специалист);
		КонецЕсли;
	КонецЕсли;
	
	Если ДокументИзменен Тогда 
		
		НовыйСпр = Справочники.ВКМ_УведомленияТелеграм_БотуДляОтправки.СоздатьЭлемент();
		НовыйСпр.ТекстСообщения = ТекстСообщения; 
		НовыйСпр.Записать();
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи); 
	
	Оповестить("Запись_ВКМ_ОбслуживаниеКлиентов",, Объект.Ссылка);

КонецПроцедуры
#КонецОбласти

#Область ОбработчикиКомандФормы

#Область ПодключаемыеКоманды

//ВКМ_Еговцева_Ольга_2024_06_19+
// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
    ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
    ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
//ВКМ_Еговцева_Ольга_2024_06_19-

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

//ВКМ_Еговцева_Ольга_2024_06_19+
&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
    ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры
//ВКМ_Еговцева_Ольга_2024_06_19-

#КонецОбласти
