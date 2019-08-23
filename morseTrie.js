/**
 * "Given an array of integers, every element appears k (k > 1) times except for one, which appears p times (p >= 1, p % k != 0). Find that single one."
 */

'use strict';
var firstUniqChar = function(s) {
    let m = new Map();
    for (const c of s) {
        m.set(c, m.get(c) ? m.get(c) + 1 : 1);
    }
    for (let i = 0; i < s.length; i++) {
        if (m.get(s[i]) === 1) {
            return i;
        }
    }
    return -1;
};
firstUniqChar('leetcode');

/**
 * @param {string[]} words
 * @return {number}
 */

var uniqueMorseRepresentations = function(words) {
    let root = new TrieNode('', false);
    words.map(word => {
        let res = '';
        for (const c of word) {
            res += morseChar[c.charCodeAt(0) - 'a'.charCodeAt(0)];
        }
        return res;
    }).forEach(val => {
        walkAndAdd(root, val, 0);
    });
    //traverse(root);
    return countChildren(root);
};
const morseChar = [".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."];


const dash = '-';
const dot = '.';

function countChildren(root) {
    if (!root) return 0;
    if (root.leaf) {
        return 1 + root.children.reduce((accumulator, current) => accumulator + countChildren(current), 0);
    }
    return root.children.reduce((accumulator, current) => accumulator + countChildren(current), 0);
}

function walkAndAdd(node, str, i) {
    if (!str || i >= str.length) return node;
    let leaf = false;
    if (str.length === i + 1) {
        leaf = true;
    }
    if (node.children.length === 0) {
        let nextNode = new TrieNode(str[i], leaf);
        node.children.push(nextNode);
        return walkAndAdd(nextNode, str, i + 1);
    } else {
        let children = node.children.filter(child => child.val === str[i]);
        if (children.length !== 0) {
            if (!children[0].leaf && leaf) {
                children[0].leaf = true;
            }
            return walkAndAdd(children[0], str, i + 1);
        } else {
            let nextNode = new TrieNode(str[i], leaf);
            node.children.push(nextNode);
            walkAndAdd(nextNode, str, i + 1);
        }
    }
    return node;
}

class TrieNode {
    constructor(val, leaf) {
        this.val = val;
        this.children = [];
        this.leaf = leaf;
    }
}

function traverse(root) {
    if (root.children.length !== 0) {
        console.log(root.children.reduce((acc, node) => acc + node.val + '  ', ''));
        root.children.forEach(node => traverse(node));
    }
}

var removeOuterParentheses = function(S) {

    if (!S || S === '') {
        return '';
    }
    let res = '';
    let stack = [];
    let start = 0;
    for (let i = 0; i < S.length; i++) {
        if (S[i] === '(') {
            stack.push('(');
        } else {
            stack.pop();
            if (stack.length === 0) {
                res += S.substring(start + 1, i);
                start = i + 1;
            }
        }
    }
    return res;

};
module.exports = {
    uniqueMorseRepresentations,
    removeOuterParentheses,

}
