---

title: updateStateByKey&mapStateWithKey
date: 2019-07-15
tags: sparkstream

---

spark中如何实现全局count

<!--more-->

## 说明

两种方式都可以实现对同一key的累计统计

区别
updateStateByKey会返回无增量数据的状态,所以会相对较大的数据资源开销
mapStateWithKey 相当于增量统计

## 使用

updateStateByKey :

```java

 public static Function2<List<Integer>, Optional<Integer>, Optional<Integer>> updateFunctionByUpdate() {
        Function2<List<Integer>, Optional<Integer>, Optional<Integer>> updateFunction = (values, s1) -> {
            Integer newSum = 0;
            if (s1.isPresent()) {
                newSum = s1.get();
            }

            Iterator<Integer> i = values.iterator();
            while (i.hasNext()) {
                newSum += i.next();
            }
            return Optional.of(newSum);
        };
        return updateFunction;
    }

```
mapStateWithKey :

```java
 public static Function3<String, Optional<Integer>, State<Integer>, Tuple2<String, Integer>> updateFunctionByMap() {
        Function3<String, Optional<Integer>, State<Integer>, Tuple2<String, Integer>> updateFunction2 = (word, one,
                                                                                                         state) -> {
            int sum = one.or(0) + (state.exists() ? state.get() : 0);
            Tuple2<String, Integer> output = new Tuple2<String, Integer>(word, sum);
            state.update(sum);
            return output;
        };
        return updateFunction2;
    }

```
